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

# Wialon Hosting server
socket = TCPSocket.open('193.193.165.165', 20163)

#socket = TCPSocket.open('localhost', 6000)

socket.send_data("74, 00, 00, 00, 33, 35, 33, 39, 37, 36, 30, 31, 33, 34, 34, 35, 34, 38, 35, 00, 4B, 0B, FB, 70, 00, 00, 00, 03, 0B, BB, 00, 00, 00, 27, 01, 02, 70, 6F, 73, 69, 6E, 66, 6F, 00, A0, 27, AF, DF, 5D, 98, 48, 40, 3A, C7, 25, 33, 83, DD, 4B, 40, 00, 00, 00, 00, 00, 80, 5A, 40, 00, 36, 01, 46, 0B, 0B, BB, 00, 00, 00, 12, 00, 04, 70, 77, 72, 5F, 65, 78, 74, 00, 2B, 87, 16, D9, CE, 97, 3B, 40, 0B, BB, 00, 00, 00, 11, 01, 03, 61, 76, 6C, 5F, 69, 6E, 70, 75, 74, 73, 00, 00, 00, 00, 01")

socket.read_accept

socket.close

