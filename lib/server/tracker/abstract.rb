require 'socket'
require 'server/abstract'
require 'timeout'

module Server; end
module Server::Tracker; end

class Server::Tracker::Abstract < Server::Abstract

  READ_TIMEOUT = 15 * 60

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

        begin
          logger.debug "#{client} connected."
          port, ip = Socket.unpack_sockaddr_in(client.getpeername)
          logger.debug "Client address: #{ip}:#{port}"

          process_data client

          linger = [1,0].pack('ii')
          client.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, linger)
          client.close
          logger.debug "#{client} connection closed."
        rescue Exception => e
          logger.debug "Error: #{e.message}"
          logger.debug "Backtrace: #{e.backtrace.join('; ')}"
        end

      end
    end
  end

  protected

    def read_data(client, size = nil, buffer_size = nil)
      data = nil
      begin
        timeout(READ_TIMEOUT) do
          data = buffer_size ? client.recv(buffer_size) : client.read(size)
        end
      rescue Timeout::Error
        raise "Socket was closed by server due to timeout."
      end

      raise "Socket was closed by server." if data.blank?

      logger.debug "Recieved data: #{get_human_data(data)}"
      data.to_s
    end

    def get_human_data(data)
      data.unpack('H2'*data.length).join(', ')
    end

end
