#!/usr/bin/env ruby

require 'socket'

def get_human_data(data)
  data.unpack('H2'*data.length).join(', ')
end

server = TCPServer.new(6000)

loop do
  client = server.accept

  data = client.recv(4)
  next if data.length < 4
  packet_size = data.unpack('V')[0]
  puts "Packet size: #{packet_size}"

  body = client.recv(packet_size)
  puts "Packet body: #{get_human_data(body)}"

  client.write("\x11")

  client.close
end
