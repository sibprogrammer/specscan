#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/server/control'

Server::Control.new({
  :command => ARGV[0],
  :pid_file => File.dirname(__FILE__) + "/../tmp/pids/retranslator.pid",
  :log_file => File.dirname(__FILE__) + "/../log/retranslator.log",
}) do
  require 'server/retranslator/sender'
  server = Server::Retranslator::Sender.new
  server.start
end
