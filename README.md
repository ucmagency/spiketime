# Settings with their default value
REDIS_HOST: "localhost"
REDIS_PORT: "6379"
REDIS_DB: "5"

# Errors
* Will raise `SpiketimeNetHTTPSError` returning the HTTP status code unless it is `200 OK`.
* Will raise `SpiketimeUnsupportedStateError` if the `state` is not given using the official abbreviation

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

# functionality:
* returns all holidays for one state of germany
* checks if a given day is a holiday for a given state (returning `true`/`false`)


# Implemented API
* https://www.spiketime.de/blog/spiketime-feiertag-api-feiertage-nach-bundeslandern/
* public postman collection: https://www.getpostman.com/collections/16ba518999fbcff4c02c


# build & install GEM locally
if previously built, remove gem file: `rm spiketime-0.0.1.gem`
```
gem build spiketime.gemspec
gem install spiketime-0.0.1.gem
```

# usage
* get all holidays for one state for one year: `holidays = Spiketime.new(state: 'BE').get_holidays('2019')` which will return an array:
```json-inline
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
* check if one particular day is a holiday in a given state: `holiday = Spiketime.new(state: 'Berlin').holiday?('2019-04-19')` which will return a boolean
