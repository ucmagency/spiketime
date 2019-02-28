require 'spiketime/spiketime'
require 'spiketime/configuration'

Spiketime.configure do |config|
  config.redis_host   = ENV.fetch('REDIS_HOST', 'localhost')
  config.redis_port   = ENV.fetch('REDIS_PORT', 6379)
  config.redis_db     = ENV.fetch('REDIS_DB', 5)
  config.redis_driver = ENV.fetch('REDIS_DRIVER', 'hiredis')
  config.logger       = nil
end
