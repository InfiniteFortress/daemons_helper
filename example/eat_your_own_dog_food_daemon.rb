# bundle exec ruby test/eat_your_own_dog_food_daemon.rb start/stop/run

require_relative '../lib/daemons_helper/daemon_base'

class EatYourOwnDogFoodDaemon < DaemonsHelper::DaemonBase
  def execute
    @logger.info "kibbles and bits and bits and bits"
  end
end

daemon = EatYourOwnDogFoodDaemon.new({
                                        process_name: __FILE__,
                                        name: 'EatYourOwnDogFoodDaemon',
                                        version: '1.0.1',
                                        #firebase_url: 'https://YOURFIREBASE.firebaseio.com',
                                        log_file_path: File.expand_path("#{File.dirname(__FILE__)}/eat_your_own_dog_food_daemon.log")
                                     })
daemon.daemonize