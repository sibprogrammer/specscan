require 'logger'
require 'date'

module Server; end

class Server::Logger < Logger

  def format_message(severity, timestamp, progname, msg)
    time = DateTime.now.strftime("%Y.%m.%d %H:%M:%S %Z")
    "#{time} - #{msg}\n"
  end

end
