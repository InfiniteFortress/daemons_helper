require 'raven'
require 'ekg'
require 'yell'
require 'daemons'
require 'eventmachine'
require 'subtle'

module DaemonsHelper
  class DaemonBase
    params_constructor
    attr_accessor :raven_dsn, :name, :version, :firebase_url, :log_file_path, :process_name, :logger

    def self.create_and_daemonize options = nil
      self.new(options).daemonize
    end

    def daemonize
      @ekg_name = @ekg_name || self.class.name
      @version = @version || '1.0.0'

      Daemons.run_proc(@process_name || "#{self.class.name}") do
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
          if @firebase_url
            Ekg.config = {
                           name: @name,
                           version: @version,
                           firebase_url: @firebase_url,
                         }
          else
            log "No firebase_url specified"
          end
          log "Starting up..."
          EventMachine.run do
            EventMachine::PeriodicTimer.new(60) do
              if @firebase_url
                log "lub dub #{@name} #{@version}"
                Ekg.lub_dub if @name && @version
              else
                log "No firebase_url specified"
              end
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
      puts(message)
    end
  end
end