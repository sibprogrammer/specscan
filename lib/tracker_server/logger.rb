require 'logger'
require 'date'

module TrackerServer

  class Logger < Logger

    def format_message(severity, timestamp, progname, msg)
      time = DateTime.now.strftime("%Y.%m.%d %H:%M:%S %Z")
      "#{time} - #{msg}\n"
    end

  end

end
