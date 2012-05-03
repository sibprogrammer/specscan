require 'server/tracker/abstract'

class Server::Tracker::Tk103b < Server::Tracker::Abstract

  def process_data(client)
    header = read_data(client)
    raise "Unrecognized header" unless header.starts_with?('##')
    send_data(client, 'LOAD')

    loop do
      data = read_data(client)
      if data.match /^\d+/
        # answer on heartbeat
        send_data(client, 'ON')
        next
      end

      packet = parse_packet(data)
      logger.debug packet.inspect

      point = WayPoint.new(packet)
      point.save
    end
  end

  private

    def read_data(client)
      data = client.recv(200)
      raise "Socket was closed by server." if data.blank?

      logger.debug "Recieved data: #{data}"
      data.to_s.chomp(';')
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
        packet[:latitude] = fields[7].to_f / 100
        packet[:latitude] = -packet[:latitude] if 'S' == fields[8]
        packet[:longitude] = fields[9].to_f / 100
        packet[:longitude] = -packet[:longitude] if 'W' == fields[10]
        packet[:speed] = fields[11].to_f
        packet[:engine_on] = packet[:speed] > 0.001
        packet[:sens_moving] = packet[:speed] > 0.001
      end

      packet
    end

end