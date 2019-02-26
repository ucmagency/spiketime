[![CircleCI](https://circleci.com/gh/ucmagency/spiketime.svg?style=svg)](https://circleci.com/gh/ucmagency/spiketime)

# General Description
This gem is just a small wrapper around the [spiketime API](https://www.spiketime.de/blog/spiketime-feiertag-api-feiertage-nach-bundeslandern/). It also offers a [postman collection](https://www.getpostman.com/collections/16ba518999fbcff4c02c).

# Dependencies
## production
* `oj` for parsing JSON
* `redis` for caching
* `faraday` for making HTTP requests

## development & testing
* `bundler`
* `mock_redis`
* `rake`
* `rspec`
* `rubocop`

# ENVs and their default fallbacks
* REDIS_HOST: `localhost`
* REDIS_PORT: `6379`
* REDIS_DB: `5`

# Usage
## Errors
* Will raise `SpiketimeNetHTTPSError` returning the HTTP status code unless it is `200 OK`.
* Will raise `SpiketimeUnsupportedStateError` if the `state` is not given using the official abbreviation

## state codes

| abbreviation | state name |
| ------------ | ---------- |
|      BW      | Baden-Würtemberg |
|      BY      | Bayern |
|      BE      | Berlin |
|      BB      | Brandenburg |
|      HB      | Bremen |
|      HH      | Hamburg |
|      HE      | Hessen |
|      MV      | Mecklenburg-Vorpommern |
|      NI      | Niedersachsen |
|      NW      | Nordrhein-Westfalen |
|      RP      | Rheinland-Pfalz |
|      SL      | Saarland |
|      SN      | Sachsen |
|      ST      | Sachsen-Anhalt |
|      SH      | Schleswig-Holstein |
|      TH      | Thüringen |

## API
* get all holidays for one state for a given year:
```ruby
holidays = Spiketime.new(state: 'BE').get_holidays('2019')

# returns an array
[
  '2019-01-01',
  '2019-04-19',
  '2019-04-21',
  '2019-04-22',
  '2019-05-01',
  '2019-05-30',
  '2019-06-09',
  '2019-06-10',
  '2019-10-03',
  '2019-12-25',
  '2019-12-26'
]
```

* check if one particular day is a holiday for a given state:
```ruby
holiday = Spiketime.new(state: 'BE').holiday?('2019-04-19')

# returns a boolean
true
```

# build & install gem locally
remove previously build gem file, build gem file, install gem, enter ruby cli:
```
rm spiketime-0.0.1.gem
gem build spiketime.gemspec
gem install spiketime-0.0.1.gem
irb
```
inside irb require gem to use it:
```ruby
require 'spiketime'
holiday = Spiketime.new(state: 'BE').holiday?('2019-04-19')
```
