#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/server/control'

server_names = %w{ galileo tk103b teltonika }
server_name = ARGV[0]
ARGV[1] = 'help' unless server_names.include? server_name

Server::Control.new({
  :command => ARGV[1],
  :pid_file => File.dirname(__FILE__) + "/../tmp/pids/tracker-server-#{server_name}.pid",
  :log_file => File.dirname(__FILE__) + "/../log/tracker-server-#{server_name}.log",
  :usage_options => "(#{server_names.join('|')}) (start|run|stop|restart|status)",
}) do
  require 'server/tracker/abstract'
  Server::Tracker::Abstract.create(server_name)
end
