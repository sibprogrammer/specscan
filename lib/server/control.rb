require 'date'

module Server; end

class Server::Control

  def initialize(options, &block)
    @pid_file = options[:pid_file]
    @log_file = options[:log_file]
    @usage_options = options[:usage_options]
    @job = block

    command = options[:command]

    case command
      when 'start' then do_start
      when 'run' then do_start(:interactive => true)
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

  def do_start(interactive = false)
    if File.exists?(@pid_file)
      puts_fail "Daemon is already running."
      exit 2
    end

    puts "Starting daemon..."

    fork_daemon unless interactive
    set_signals_handlers
    write_pid_file
    load_rails_env

    @job.call

    delete_pid_file
  end

  def do_stop
    if (File.exists?(@pid_file))
      pid = File.read(@pid_file).to_i

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
    if (File.exists?(@pid_file))
      pid = File.read(@pid_file).to_i

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
    @usage_options ||= "(start|run|stop|restart|status)"
    puts "Usage: ruby #{$0} #{@usage_options}"
    exit 1
  end

  def fork_daemon
    raise 'Failed to fork child.' if (pid = fork) == -1
    exit 0 unless pid.nil?

    Process.setsid
    raise 'Failed to create daemon.' if (pid = fork) == -1
    exit 0 unless pid.nil?

    STDIN.reopen '/dev/null'
    STDOUT.reopen(@log_file, 'a')
    STDERR.reopen STDOUT
  end

  def set_signals_handlers
    Signal.trap('HUP', 'IGNORE')
    ['INT', 'TERM'].each { |signal| trap(signal) { shutdown } }
  end

  def write_pid_file
    log "Daemon PID: #{Process.pid}"
    open(@pid_file, "w") { |file| file.write(Process.pid) }
  end

  def delete_pid_file
    File.unlink @pid_file if File.exists?(@pid_file)
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