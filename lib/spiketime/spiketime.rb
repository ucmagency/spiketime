#
# fetch public holidays for a given state of germany and cache using redis to reduce amount of HTTP calls to foreign API
# see: https://www.spiketime.de/blog/spiketime-feiertag-api-feiertage-nach-bundeslandern/
# public postman collection: https://www.getpostman.com/collections/16ba518999fbcff4c02c
#

require 'faraday'
require 'redis'
require 'oj'

class SpiketimeNetHTTPSError < StandardError; end
class SpiketimeUnsupportedStateError < StandardError; end

class Spiketime
  # official abbreviations for states in Germany
  STATE_CODES = {
    'BW' => 'Baden-Würtemberg',
    'BY' => 'Bayern',
    'BE' => 'Berlin',
    'BB' => 'Brandenburg',
    'HB' => 'Bremen',
    'HH' => 'Hamburg',
    'HE' => 'Hessen',
    'MV' => 'Mecklenburg-Vorpommern',
    'NI' => 'Niedersachsen',
    'NW' => 'Nordrhein-Westfalen',
    'RP' => 'Rheinland-Pfalz',
    'SL' => 'Saarland',
    'SN' => 'Sachsen',
    'ST' => 'Sachsen-Anhalt',
    'SH' => 'Schleswig-Holstein',
    'TH' => 'Thüringen'
  }.freeze

  def initialize(force: false, state:)
    raise SpiketimeUnsupportedStateError, state unless STATE_CODES.keys.include?(state)

    @redis = setup_redis
    @https = establish_connection
    @force = force
    @state = state
  end

  # returns an array of dates, accepts a year (YYYY) as parameter
  def get_holidays(year = Time.current.year)
    cache = force ? nil : get_cached_holidays(state, year)
    return Oj.load(cache) if cache

    response = get("feiertage/#{state}/#{year}")
    raise SpiketimeNetHTTPSError, response.status unless response.status == 200

    # store in format `YYYY-MM-DD`
    holidays = Oj.load(response.body).map do |holiday|
      holiday['Datum'].split('T').first
    end
    cache_holidays(state, year, holidays)

    holidays
  end

  # expects a date as input, either as Date object or string `YYYY-MM-DD`
  def holiday?(date = Date.current.to_s)
    holidays = get_holidays(date.to_s[0..3])
    holidays.include?(date.to_s)
  end

  private

  attr_reader :https, :redis, :force, :state

  def setup_redis
    Redis.new(host: Spiketime.configuration.redis_host,
              port: Spiketime.configuration.redis_port,
              db: Spiketime.configuration.redis_db,
              driver: Spiketime.configuration.redis_driver)
  end

  def establish_connection
    Faraday.new(url: 'https://www.spiketime.de')
  end

  def get(path)
    https.get("/feiertagapi/#{path}")
  end

  def get_cached_holidays(state, year)
    begin
      redis.get("spiketime:holidays:#{state}:#{year}")
    rescue Redis::TimeoutError => ex
      Spiketime.configuration.logger.error(ex)
    end
  end

  def cache_holidays(state, year, holidays)
    redis.set("spiketime:holidays:#{state}:#{year}", holidays)
  end
end
