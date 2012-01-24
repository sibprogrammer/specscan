require "getoptlong"
require 'tracker_server/galileo'

$PORT = 1234

opts = GetoptLong.new(
  ["--port", "-p", GetoptLong::REQUIRED_ARGUMENT]
)

opts.each do |opt, arg|
  $PORT = arg if '--port' == opt
end

server = TrackerServer::Galileo.new($PORT)
server.start

