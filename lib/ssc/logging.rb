module Logging
  def looger
    Logging.logger
  end

  def self.log msg
    puts msg
    logger.info msg
  end

  def self.logger
    @logger ||= Logger.new '/data/ssc/ssc.log', 'weekly'
  end
end
