require 'server/tracker/abstract'
require 'digest/crc16'

class Server::Tracker::Teltonika < Server::Tracker::Abstract

  READ_BUFFER_BYTES = 8192

  def process_data(client)
    imei_header = read_data(client)
    imei = imei_header[2,15]
    logger.debug "IMEI: #{imei}"

    # send accept packet
    send_data(client, "\001")

    loop do
      begin
        header = read_data(client, 8)
      rescue Exception => e
        logger.debug "#{e.message}"
        return
      end

      data_length = header[4,4].unpack('N')[0]
      logger.debug "AVL data length: #{data_length}"

      body = read_data(client, data_length + 4)
      logger.debug "Body data size: #{body.size}"

      raise 'Unknown codec ID' unless 8 == body[0]
      records_count = body[1]
      logger.debug "Records count: #{records_count}"
      bytes_offset = 2

      1.upto(records_count).each do |record_index|
        packet = { :imei => imei }
        packet[:timestamp] = body[bytes_offset, 8].reverse.unpack('Q')[0] / 1000
        bytes_offset += 8
        bytes_offset += 1 # ignore priority
        packet[:longitude] = body[bytes_offset, 4].unpack('N')[0].to_f / 10000000
        bytes_offset += 4
        packet[:latitude] = body[bytes_offset, 4].unpack('N')[0].to_f / 10000000
        bytes_offset += 4
        packet[:height] = body[bytes_offset, 2].unpack('n')[0]
        bytes_offset += 2
        packet[:direction] = body[bytes_offset, 2].unpack('n')[0]
        bytes_offset += 2
        packet[:satellites] = body[bytes_offset]
        packet[:coors_valid] = packet[:satellites] > 0
        bytes_offset += 1
        packet[:speed] = body[bytes_offset, 2].unpack('n')[0]
        bytes_offset += 2

        if packet[:coors_valid]
          packet[:engine_on] = packet[:speed] > 0.001
          packet[:sens_moving] = packet[:speed] > 0.001
        end

        event_io_id = body[bytes_offset]
        bytes_offset += 1
        total_io_values = body[bytes_offset]
        bytes_offset += 1
        total_1byte_io = body[bytes_offset]
        bytes_offset += 1 + total_1byte_io * 2
        total_2bytes_io = body[bytes_offset]
        bytes_offset += 1 + total_2bytes_io * 3
        total_4bytes_io = body[bytes_offset]
        bytes_offset += 1 + total_4bytes_io * 5
        total_8bytes_io = body[bytes_offset]
        bytes_offset += 1 + total_8bytes_io * 9

        logger.debug packet.inspect
        WayPoint.create(packet)
      end

      raise "Number of records does not match" if body[bytes_offset] != records_count
      bytes_offset += 1

      calculated_sum = Digest::CRC16.hexdigest(body[0, body.length-4]).hex
      logger.debug "calculated checksum: #{calculated_sum}"

      check_sum = body[-4,4].unpack("N")[0]
      logger.debug "packet checksum: #{check_sum}"

      raise "Invalid checksum (#{check_sum} vs #{calculated_sum})" unless calculated_sum == check_sum

      # send accept with number of accepted records
      send_data(client, [records_count].pack('N'))
    end
  end

  private

    def read_data(client, size = nil)
      data = !size ? client.recv(READ_BUFFER_BYTES) : client.read(size)
      raise "Socket was closed by server." if data.blank?

      logger.debug "Recieved data: #{get_human_data(data)}"
      data.to_s
    end

    def send_data(client, data)
      client.write(data)
      logger.debug "Sent data: #{get_human_data(data)}"
    end

    def get_human_data(data)
      data.unpack('H2'*data.length).join(', ')
    end

end
