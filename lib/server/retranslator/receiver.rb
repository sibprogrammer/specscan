require 'socket'

module Server; end
module Server::Retranslator; end

class Server::Retranslator::Receiver

  attr_reader :host, :port

  def initialize(host, port)
    @host = host
    @port = port
  end

  def send(way_points)
    socket = TCPSocket.open(@host, @port)

    way_points.each do |way_point|
      send_packet(socket, way_point)
    end

    socket.close
  end

  private

    def send_packet(socket, way_point)
      data = ''

      data += way_point.imei + "\x00"
      data += [way_point.timestamp].pack('N')

      # position info
      flags = 1
      data += [flags].pack('N')

      # non-documented constant
      block_type = "\x0B\xBB"
      data += block_type

      # predefined size of posinfo block
      block_size = 39
      data += [block_size].pack('N')

      # block is hidden or not (1 means hidden)
      block_hidden = 1
      data += [block_hidden].pack('C')

      # block data is binary
      block_data_type = 2
      data += [block_data_type].pack('C')

      data += "posinfo" + "\x00"
      data += [way_point.longitude].pack('E')
      data += [way_point.latitude].pack('E')
      data += [way_point.height.to_f].pack('E')
      data += [way_point.speed].pack('n')
      data += [way_point.direction.to_i].pack('n')
      satellites = way_point.satellites? ? way_point.satellites : 10
      data += [way_point.satellites.to_i].pack('C')

      packet_size = data.length
      data = [packet_size].pack('V') + data

      socket.write(data)

      accept = socket.read(1).unpack('C')[0]
      raise "Data was not accepted by server" if 0x11 != accept
    end

end
