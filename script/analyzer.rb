#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/server/control'

Server::Control.new({
  :command => ARGV[0],
  :pid_file => File.dirname(__FILE__) + "/../tmp/pids/analyzer.pid",
  :log_file => File.dirname(__FILE__) + "/../log/analyzer.log",
}) do
  require 'server/analyzer'
  server = Server::Analyzer.new
  server.start
end
