require 'server/abstract'
require 'server/retranslator/receiver'

module Server; end

class Server::Retranslator::Sender < Server::Abstract

  def initialize
    @log_file = "#{Rails.root}/log/retranslator.log"
    init_receivers
  end

  def start
    loop do
      @receivers.each do |receiver|
        logger.debug "Retranslating data to server #{receiver.host}:#{receiver.port}"
        Vehicle.with_retranslate.each do |vehicle|
          points = vehicle.points_to_retranslate(1).all
          next if points.blank?

          logger.debug "Found way points for vehicle ##{vehicle.id} (IMEI #{vehicle.imei}): #{points.count}"

          begin
            receiver.send(points)
            logger.debug "Data was accepted by the server."
          rescue Exception => e
            logger.debug "Failed to send data to the server: #{e}"
            #logger.debug "Backtrace: #{e.backtrace.join('; ')}"
          end
        end
      end

      sleep(1.minute.to_i)
    end
  end

  private

    def init_receivers
      @receivers = []
      config_file = "#{Rails.root}/config/retranslators.yml"
      return unless File.exists?(config_file)

      config = YAML.load_file(config_file)

      config.each do |retranslator_config|
        @receivers << Server::Retranslator::Receiver.new(retranslator_config['host'], retranslator_config['port'])
      end
    end

end

