require 'date'

module TrackerServer
  class Control

    PID_FILE = File.dirname(__FILE__) + '/../../tmp/pids/tracker-server.pid'

    def initialize
      command = ARGV[0]

      case command
        when 'start' then do_start
        when 'stop' then do_stop
        when 'restart' then do_restart
        when 'status' then do_status
        else do_help
      end
    end

    def do_start
      puts "Starting daemon..."

      fork_daemon
      write_pid_file
      load_rails_env

      require 'tracker_server/galileo'
      server = TrackerServer::Galileo.new(1234)
      server.start

      delete_pid_file
    end

    def do_stop
      if (File.exists?(PID_FILE))
        pid = File.read(PID_FILE)
        begin
          Process.kill('TERM', pid.to_i)
        rescue
          delete_pid_file
        end
      end

      puts "Daemon was stopped."
    end

    def do_restart
      do_stop
      do_start
    end

    def do_status
      # TODO: validate process presense by Process.kill(0, pid)

      if (File.exists?(PID_FILE))
        puts "Daemon is running."
      else
        puts "Daemon is stopped."
        exit(1)
      end
    end

    def do_help
      puts "Usage: ruby #{$0} (start|stop|restart|status)"
      exit 1
    end

    def fork_daemon
      raise 'Failed to fork child.' if (pid = fork) == -1
      exit 2 unless pid.nil?

      Process.setsid
      raise 'Failed to create daemon.' if (pid = fork) == -1
      exit 2 unless pid.nil?

      Signal.trap('HUP', 'IGNORE')
      ['INT', 'TERM'].each { |signal| trap(signal) { shutdown } }

      STDIN.reopen '/dev/null'
      STDOUT.reopen(File.dirname(__FILE__) + '/../../log/tracker-server.log', 'a')
      STDERR.reopen STDOUT
    end

    def write_pid_file
      log "Daemon PID: #{Process.pid}"
      open(PID_FILE, "w") { |file| file.write(Process.pid) }
    end

    def delete_pid_file
      File.unlink PID_FILE if File.exists?(PID_FILE)
    end

    def load_rails_env
      path = File.dirname(__FILE__) + '/../..'
      require "#{path}/config/boot"
      require "#{path}/config/environment"
    end

    def shutdown
      log "Shutdown daemon."
      delete_pid_file
      exit(0)
    end

    def log(message)
      time = DateTime.now.strftime("%Y.%m.%d %H:%M:%S %Z")
      puts "#{time} - #{message}"
      STDOUT.flush
    end

  end
end
