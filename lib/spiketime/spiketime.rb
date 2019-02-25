#
# fetch public holidays for a given state of germany and cache using redis to reduce amount of HTTP calls to foreign API
# see: https://www.spiketime.de/blog/spiketime-feiertag-api-feiertage-nach-bundeslandern/
# public postman collection: https://www.getpostman.com/collections/16ba518999fbcff4c02c
#

require 'net/https'
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
    @http  = establish_https_connection
    @force = force
    @state = state
  end

  # returns an array of dates, accepts a year (YYYY) as parameter
  def get_holidays(year = Time.current.year)
    cache = force ? nil : get_cached_holidays(state, year)
    return Oj.load(get_cached_holidays(state, year)) if cache

    response = get("/feiertage/#{state}/#{year}")
    raise SpiketimeNetHTTPSError, response.code unless response.code == 200

    # store in format `YYYY-MM-DD`
    holidays = Oj.load(response.body).map do |holiday|
      holiday.symbolize_keys[:Datum].split('T').first
    end
    cache_holidays(state, year, holidays)

    holidays
  end

  # expects a date as input, either as Date object or string `YYYY-MM-DD`
  def holiday?(date = Date.current.to_s)
    holidays = get_holidays(date.to_s[0..4])
    holidays.include?(date.to_s)
  end

  private

  attr_reader :http, :redis, :force, :state

  def setup_redis
    Redis.new(host: redis_host, port: redis_port, db: redis_db)
  end

  def establish_https_connection
    http = Net::HTTP.new('https://www.spiketime.de', 433)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http
  end

  def get(path)
    http.request(Net::HTTP::Get.new(path))
  end

  def get_cached_holidays(state, year)
    redis.get("spiketime:holidays:#{state}:#{year}")
  end

  def cache_holidays(state, year, holidays)
    redis.set("spiketime:holidays:#{state}:#{year}", holidays)
  end
end
