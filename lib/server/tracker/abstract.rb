require 'socket'
require 'server/abstract'

module Server; end
module Server::Tracker; end

class Server::Tracker::Abstract < Server::Abstract

  def self.create(server_name)
    require "server/tracker/#{server_name}"
    server = Server::Tracker.const_get(server_name.capitalize).new(server_name)
    server.start
  end

  def initialize(server_name)
    @server_name = server_name
    @config = YAML.load_file("#{Rails.root}/config/tracker-server.yml")[@server_name]
    @port = @config['port']
    @server = TCPServer.new @port
    @log_file = "#{Rails.root}/log/tracker-server-#{@server_name}.log"
    logger.debug "Starting #{@server_name} tracker server on port #{@port}..."
  end

  def start
    # workaround for clients with incorrect DNS records
    Socket.do_not_reverse_lookup = true

    loop do
      Thread.start(@server.accept) do |client|
        logger.debug "#{client} connected."

        port, ip = Socket.unpack_sockaddr_in(client.getpeername)
        logger.debug "Client address: #{ip}:#{port}"

        begin
          process_data client
        rescue Exception => e
          logger.debug "Error: #{e.message}"
          logger.debug "Backtrace: #{e.backtrace.join('; ')}"
        end

        client.close
        logger.debug "#{client} connection closed."
      end
    end
  end

end
