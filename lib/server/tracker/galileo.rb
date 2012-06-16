require 'server/tracker/abstract'
require 'digest/crc16_modbus'

class Server::Tracker::Galileo < Server::Tracker::Abstract

  CHECKSUM_BYTES = 2
  HEADER_SIZE = 3

  def process_data(client)
    head_packet = read_packet(client)
    logger.debug head_packet.inspect

    raise "Head packet has no IMEI" unless head_packet.key?(:imei)

    loop do
      packet = read_packet(client)
      packet.merge! head_packet

      logger.debug packet.inspect
      logger.debug "IMEI #{packet[:imei]} record id: #{packet[:record_id]}" if packet.key?(:record_id)

      point = WayPoint.new(packet)
      if packet.key?(:timestamp) and (Time.now.to_i - packet[:timestamp]) > 1.year.to_i
        logger.debug "Packet with very old timestamp was recieved - #{packet[:timestamp]}"
      else
        point.save
      end
    end
  end

  def get_packet_size(raw_size)
    hi_byte = ~0x80 & raw_size[1]
    low_byte = raw_size[0]
    (hi_byte << 8) + low_byte
  end

  def get_human_data(data)
    data.unpack('H2'*data.length).join(', ')
  end

  def read_packet(client)
    data = read_data(client, HEADER_SIZE)
    packet_size = get_packet_size(data[1,2])

    data += read_data(client, packet_size + CHECKSUM_BYTES)
    packet = parse_packet(data[HEADER_SIZE, data.length - CHECKSUM_BYTES - HEADER_SIZE])
    send_accept(client, data)
    packet
  end

  def read_data(client, size)
    logger.debug "reading data (size: #{size})..."
    data = client.read(size)
    raise "Socket was closed by server." if data.nil?
    logger.debug get_human_data(data)
    data
  end

  def parse_packet(data)
    packet = {}
    index = 1

    while index < data.length do
      tag = data[index-1]

      case tag
        when 0x01
          value_length = 1
          packet[:hardware_version] = data[index]
        when 0x02
          value_length = 1
          packet[:firmware_version] = data[index]
        when 0x03
          value_length = 15
          packet[:imei] = data[index,value_length]
        when 0x04
          value_length = 2
          packet[:device_id] = data[index,value_length].unpack('v')[0]
        when 0x10
          value_length = 2
          packet[:record_id] = data[index,value_length].unpack('v')[0]
        when 0x20
          value_length = 4
          packet[:timestamp] = data[index,value_length].unpack('V')[0]
        when 0x30
          value_length = 9
          coors = {}
          first_byte = data[index,1].unpack('C')[0]
          packet[:coors_valid] = (first_byte >> 4) == 0
          packet[:satellites] = (first_byte & ~0xF0)
          packet[:latitude] = data[index+1,4].unpack('l<')[0].to_f / 1000000
          packet[:longitude] = data[index+5,4].unpack('l<')[0].to_f / 1000000
          packet[:coors_valid] = false if packet[:coors_valid] and ((0 - packet[:latitude]).abs < 0.1 or (0 - packet[:longitude]).abs < 0.1)
        when 0x33
          value_length = 4
          packet[:speed] = data[index,2].unpack('v')[0].to_f / 10
          packet[:direction] = data[index+2,2].unpack('s<')[0].to_f / 10
        when 0x34
          value_length = 2
          packet[:height] = data[index,value_length].unpack('s<')[0]
        when 0x35
          value_length = 1
          packet[:hdop] = data[index].to_f / 10
        when 0x40
          value_length = 2
          status = data[index,value_length].unpack('v')[0]
          packet[:status] = status
          packet[:sens_moving] = 1 == (status & 1)
          packet[:bad_angle] = 2 == (status & 2)
          packet[:int_power_low] = 32 == (status & 32)
          packet[:gps_antenna] = 0 == (status & 64)
          packet[:int_bus_power_low] = 128 == (status & 128)
          packet[:ext_power_low] = 256 == (status & 256)
          packet[:engine_on] = 512 == (status & 512)
          packet[:sens_hit] = 1024 == (status & 1024)
          packet[:glonass] = 2048 == (status & 2048)
          packet[:signal] = (status & 12288) >> 12
          packet[:alarm_mode] = 16384 == (status & 16384)
          packet[:alarm] = 32768 == (status & 32768)
        when 0x41
          value_length = 2
          packet[:int_power] = data[index,value_length].unpack('v')[0]
        when 0x42
          value_length = 2
          packet[:ext_power] = data[index,value_length].unpack('v')[0]
        when 0x43
          value_length = 1
          packet[:temperature] = data[index,value_length].unpack('c')[0]
        when 0x44
          value_length = 4
          acceleration = data[index,value_length].unpack('V')[0]
          packet[:acceleration_x] = acceleration & 1023
          packet[:acceleration_y] = (acceleration & (1023 << 10)) >> 10
          packet[:acceleration_z] = (acceleration & (1023 << 20)) >> 20
        when 0x45
          value_length = 2
          packet[:output_statuses] = data[index,value_length].unpack('v')[0]
        when 0x46
          value_length = 2
          packet[:input_statuses] = data[index,value_length].unpack('v')[0]
        when 0x50
          value_length = 2
          packet[:power_input_0] = data[index,value_length].unpack('v')[0]
        when 0x51
          value_length = 2
          packet[:power_input_1] = data[index,value_length].unpack('v')[0]
        when 0x52
          value_length = 2
          packet[:power_input_2] = data[index,value_length].unpack('v')[0]
        when 0x53
          value_length = 2
          packet[:power_input_3] = data[index,value_length].unpack('v')[0]
        when 0x58
          value_length = 2
          packet[:rs232_0] = data[index,value_length].unpack('v')[0]
        when 0x59
          value_length = 2
          packet[:rs232_1] = data[index,value_length].unpack('v')[0]
        when 0x70..0x77
          value_length = 2
          therm_id = tag - 0x70
          packet["thermometer_#{therm_id}".to_sym] = data[index+1,1].unpack('c')[0]
        when 0x90
          value_length = 4
          packet[:ibutton] = data[index,value_length].unpack('V')[0]
        when 0xc0
          value_length = 4
          packet[:fms_fuel_consumed] = data[index,value_length].unpack('V')[0].to_f / 2
        when 0xc1
          value_length = 4
          packet[:fms_fuel] = (data[index,1].unpack('C')[0] * 0.4).to_i
          packet[:antifreeze] = (data[index+1,1].unpack('C')[0] - 40).to_i
          packet[:eninge_rpm] = (data[index+2,2].unpack('v')[0] * 0.125).to_i
        when 0xc2
          value_length = 4
          packet[:fms_distance] = data[index,value_length].unpack('V')[0] * 5
        when 0xc3
          value_length = 4
          packet[:can_b1] = data[index,value_length].unpack('V')[0]
        when 0xc4..0xd5
          value_length = 1
          bit_num = tag - 0xc4
          packet["can8bitr#{bit_num}".to_sym] = data[index,value_length].unpack('C')[0]
        when 0xd6..0xda
          value_length = 2
          bit_num = tag - 0xd6
          packet["can16bitr#{bit_num}".to_sym] = data[index,value_length].unpack('v')[0]
        when 0xdb..0xdf
          value_length = 4
          bit_num = tag - 0xdb
          packet["can32bitr#{bit_num}".to_sym] = data[index,value_length].unpack('V')[0]
        else
          logger.debug "Unknown tag #{tag} found in packet."
          break
      end

      index += 1 + value_length
    end

    packet
  end

  def send_accept(client, data)
    logger.debug get_human_data(data[0, data.length-2])
    calculated_sum = Digest::CRC16Modbus.hexdigest(data[0, data.length-2]).hex
    logger.debug "calculated checksum: #{calculated_sum}"

    check_sum = data[-2,2].unpack("v")[0]
    logger.debug "packet checksum: #{check_sum}"

    raise "Invalid checksum (#{check_sum} vs #{calculated_sum})" unless calculated_sum == check_sum

    accept_data = "\x02" + data[-2,2]
    logger.debug get_human_data(accept_data)
    client.write(accept_data)
  end

end
