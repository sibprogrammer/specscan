require 'server/logger'

module Server; end

class Server::Abstract

  def logger
    return @logger if @logger
    file = STDOUT.tty? ? STDOUT : File.open(@log_file, 'a')
    file.sync = true
    @logger = Server::Logger.new(file)
  end

end