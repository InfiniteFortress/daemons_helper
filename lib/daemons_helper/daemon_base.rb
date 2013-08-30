require 'raven'
require 'heartbeat'
require 'yell'
require 'daemons'
require 'eventmachine'
require 'subtle'

module DaemonsHelper
  class DaemonBase
    params_constructor
    attr_accessor :raven_dsn, :heartbeat_name, :heartbeat_version, :log_file_path, :process_name, :logger

    def self.create_and_daemonize options = nil
      self.new(options).daemonize
    end

    def daemonize
      Heartbeat.config = {
                       name: @heartbeat_name,
                       version: @heartbeat_version
                     }

      Daemons.run_proc(@process_name) do
        mutex = Mutex.new
        operation_running = false
        operation = proc {
          self.execute
        }
        callback = proc {|result|
          mutex.synchronize do
            operation_running = false
          end
        }

        Raven.configure do |config|
          config.dsn = @raven_dsn if @raven_dsn
        end

        Raven.capture do
          setup_the_logger
          log "Starting up..."
          EventMachine.run do
            EventMachine::PeriodicTimer.new(60) do
              Heartbeat.lub_dub if @heartbeat_name && @heartbeat_version
            end
            EventMachine::PeriodicTimer.new(1) do
              mutex.synchronize do
                if !operation_running
                  operation_running = true
                  EventMachine.defer(operation, callback)
                end
              end
            end
          end
        end
      end
    end

    private

    def setup_the_logger
      return unless @log_file_path
      @logger = Yell.new do |l|
        l.level = :info # will only pass :info and above to the adapters
        l.adapter :datefile, @log_file_path, :level => Yell.level.lte(:warn)
        l.adapter :datefile, @log_file_path, :level => Yell.level.gte(:error)
      end
    end

    def log message
      @logger.info(message) if @logger
      puts(message) unless @logger
    end
  end
end