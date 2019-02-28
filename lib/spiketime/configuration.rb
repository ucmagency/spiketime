class Spiketime
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :redis_host, :redis_port, :redis_db, :redis_driver, :logger

    def initialize
      @redis_host   = 'REDIS_HOST'
      @redis_port   = 'REDIS_PORT'
      @redis_db     = 'REDIS_DB'
      @redis_driver = 'REDIS_DRIVER'
      @logger       = nil
    end
  end
end
