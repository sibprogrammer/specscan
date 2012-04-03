require 'date'

module TrackerServer
  class Control

    PID_FILE = File.dirname(__FILE__) + '/../../tmp/pids/tracker-server.pid'
    LOG_FILE = File.dirname(__FILE__) + '/../../log/tracker-server.log'

    def initialize
      command = ARGV[0]

      case command
        when 'start' then do_start
        when 'stop' then exit do_stop
        when 'restart' then do_restart
        when 'status' then do_status
        else do_help
      end
    end

    def puts_ok(message)
      puts "\033[00;32m[OK]\033[00m " + message
    end

    def puts_fail(message)
      puts "\033[00;31m[FAIL]\033[00m " + message
    end

    def do_start
      if File.exists?(PID_FILE)
        puts_fail "Daemon is already running."
        exit 2
      end

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
        pid = File.read(PID_FILE).to_i

        begin
          Process.kill(0, pid)
        rescue
          puts_fail "Daemon probably died."
          delete_pid_file
          return 1
        end

        begin
          Process.kill('TERM', pid)
        rescue
          puts_fail "Unable to stop daemon."
        end
      end

      puts_ok "Daemon was stopped."
      return 0
    end

    def do_restart
      do_stop
      do_start
    end

    def do_status
      if (File.exists?(PID_FILE))
        pid = File.read(PID_FILE).to_i

        begin
          Process.kill(0, pid)
        rescue
          puts_fail "Daemon probably died."
          exit 1
        end

        puts_ok "Daemon is running."
      else
        puts_fail "Daemon is stopped."
        exit 1
      end
    end

    def do_help
      puts "Usage: ruby #{$0} (start|stop|restart|status)"
      exit 1
    end

    def fork_daemon
      raise 'Failed to fork child.' if (pid = fork) == -1
      exit 0 unless pid.nil?

      Process.setsid
      raise 'Failed to create daemon.' if (pid = fork) == -1
      exit 0 unless pid.nil?

      Signal.trap('HUP', 'IGNORE')
      ['INT', 'TERM'].each { |signal| trap(signal) { shutdown } }

      STDIN.reopen '/dev/null'
      STDOUT.reopen(LOG_FILE, 'a')
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
      exit 0
    end

    def log(message)
      time = DateTime.now.strftime("%Y.%m.%d %H:%M:%S %Z")
      puts "#{time} - #{message}"
      STDOUT.flush
    end

  end
end
