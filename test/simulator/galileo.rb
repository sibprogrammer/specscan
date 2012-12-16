#!/usr/bin/env ruby

require 'socket'

class TCPSocket
  def send_data(data)
    raw_data = data.split(', ').join.to_a.pack('H*') 
    write(raw_data)
    STDERR.puts "Sent data: #{data}"
  end

  def read_accept
    accept = read(3).unpack('H*')
    STDERR.puts "Accept: #{accept.join(', ')}"
  end
end

puts "Packet with valid coordinates"
socket = TCPSocket.open('localhost', 5000)
socket.send_data("01, 17, 80")
socket.send_data("01, 0f, 02, 7f, 03, 38, 36, 38, 32, 30, 34, 30, 30, 31, 33, 30, 31, 30, 38, 33, 04, 32, 00, df, 7f")
socket.read_accept
socket.send_data("01, 39, 00")
socket.send_data("04, 32, 00, 10, 91, 2e, 20, 86, cc, cd, 50, 30, 08, d8, 58, 48, 03, f8, 0a, f1, 04, 33, 00, 00, bc, 02, 34, 71, 00, 35, 09, 40, 21, 3a, 41, 56, 6e, 42, d9, 0d, 43, ff, 46, 01, e0, 50, 8f, 6e, 51, 00, 00, 58, 00, 00, 59, 00, 00, 5a, 11")
socket.read_accept
socket.close

