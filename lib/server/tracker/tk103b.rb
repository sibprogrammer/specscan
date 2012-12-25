require 'server/tracker/abstract'

class Server::Tracker::Tk103b < Server::Tracker::Abstract

  SPEED_KM_PER_KNOT = 1.852
  REPLY_INTERVAL = '5s'
  READ_BUFFER_BYTES = 8192

  def process_data(client)
    @prev_points = {}
    loop do
      data = read_data(client, nil, READ_BUFFER_BYTES)
      data.split(';').each do |packet|
        next if packet.to_s.chomp.empty?
        process_packet(client, packet)
      end
    end
  end

  private

    def process_packet(client, data)
      if data.starts_with?('##')
        # process header
        send_data(client, 'LOAD')
        imei = data.split(',')[1].split(':').last
        logger.debug "Tracker IMEI: #{imei}"
        send_data(client, "**,imei:#{imei},C,#{REPLY_INTERVAL}")
      elsif data.match /^\d+/
        # answer on heartbeat
        send_data(client, 'ON')
      elsif data.starts_with?('imei:')
        # process regular packet
        packet = parse_packet(data)
        logger.debug packet.inspect

        if !packet[:coors_valid]
          logger.debug "Ignoring way point with invalid coordinates."
          return
        end

        prev_point = @prev_points[packet[:imei]]
        unless prev_point and packet[:coors_valid] and (0 == packet[:speed].to_i) and (0 == prev_point[:speed].to_i) and (packet[:timestamp].to_i - prev_point[:timestamp].to_i) < 5.minutes
          point = WayPoint.new(packet)
          point.save
          @prev_points[packet[:imei]] = point
        else
          logger.debug "Ignoring way point cause it is equal to previous one."
        end
      else
        raise "Unrecognized data packet #{data}"
      end
    end

    def send_data(client, data)
      client.write(data)
      logger.debug "Sent data: #{data}"
    end

    def parse_packet(data)
      fields = data.chomp.split(',')
      logger.debug("Data fields: #{fields.inspect}")

      packet = {}

      packet[:imei] = fields[0].split(':').last
      packet[:timestamp] = Time.now.to_i

      gps_ok = 'F' == fields[4]
      data_ok = 'A' == fields[6]

      packet[:coors_valid] = gps_ok and data_ok

      if packet[:coors_valid]
        packet[:latitude] = coors_to_degrees(fields[7].to_f)
        packet[:latitude] = -packet[:latitude] if 'S' == fields[8]
        packet[:longitude] = coors_to_degrees(fields[9].to_f)
        packet[:longitude] = -packet[:longitude] if 'W' == fields[10]
        packet[:speed] = fields[11].to_f * SPEED_KM_PER_KNOT
        packet[:engine_on] = packet[:speed] > 0.001
        packet[:sens_moving] = packet[:speed] > 0.001
      end

      packet
    end

    def coors_to_degrees(coor)
      (coor / 100).truncate + ((coor / 100).remainder(1) * 10 / 6)
    end

end
