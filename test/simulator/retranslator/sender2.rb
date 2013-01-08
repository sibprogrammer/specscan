#!/usr/bin/env ruby

require 'ostruct'
require 'lib/server/retranslator/receiver'

packet = OpenStruct.new({
  :imei => '868204001194264',
  :timestamp => Time.now.to_i,
  :longitude => 82.9596,
  :latitude => 55.045912,
  :speed => 50,
  :direction => 300,
  :satellites => 11,
})

host = ARGV[0]
port = ARGV[1]

receiver = Server::Retranslator::Receiver.new(host, port)
receiver.send([packet])
