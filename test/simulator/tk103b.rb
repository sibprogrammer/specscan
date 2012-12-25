#!/usr/bin/env ruby

require 'socket'

class TCPSocket
  def send_data(data)
    raw_data = data.split(', ').join.to_a.pack('H*')
    write(raw_data)
    STDERR.puts "Sent data: #{data}"
  end

  def read_accept
    accept = read(1).unpack('H*')
    STDERR.puts "Accept: #{accept.join(', ')}"
  end
end

puts "Packet with valid coordinates"
socket = TCPSocket.open('localhost', 5100)
socket.send_data("69, 6d, 65, 69, 3a, 30, 31, 32, 34, 39, 37, 30, 30, 30, 38, 38, 38, 32, 37, 35, 2c, 74, 72, 61, 63, 6b, 65, 72, 2c, 31, 32, 31, 32, 32, 35, 30, 37, 32, 35, 2c, 2c, 46, 2c, 32, 33, 32, 35, 33, 39, 2e, 30, 30, 30, 2c, 41, 2c, 35, 35, 30, 33, 2e, 32, 34, 39, 33, 2c, 4e, 2c, 30, 38, 32, 35, 37, 2e, 37, 32, 31, 34, 2c, 45, 2c, 30, 2e, 30, 30, 2c, 3b")

puts "Packet with invalid coordinates"
socket.send_data("69, 6d, 65, 69, 3a, 33, 35, 33, 34, 35, 31, 30, 34, 39, 34, 34, 37, 31, 38, 36, 2c, 74, 72, 61, 63, 6b, 65, 72, 2c, 30, 30, 3
0, 30, 30, 30, 30, 30, 30, 30, 2c, 2c, 4c, 2c, 3b")

socket.close
