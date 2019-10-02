# Logstash Filter Rediss Plugin

[![Build Status](https://travis-ci.org/thiagobarradas/logstash-filter-rediss.svg)](https://travis-ci.org/thiagobarradas/logstash-filter-rediss)
[![Gem Version](https://badge.fury.io/rb/logstash-filter-rediss.svg)](https://badge.fury.io/rb/logstash-filter-rediss)
[![GitHub license](https://img.shields.io/github/license/thiagobarradas/logstash-filter-rediss.svg)](https://github.com/thiagobarradas/logstash-filter-rediss)

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is MIT, see [LICENSE](http://github.com/thiagobarradas/logstash-filter-rediss/LICENSE) for further infos.

## Documentation

Actions allowed:
- `get` - Get cache with key in :get and set value in :target
- `set` - Set cache with key in :set and value from :source
- `setex` - Set cache with key in :setex, considering TTL from :ttl (in seconds) and value from :source
- `exists` - Checks if key :exists exists and save result in :target
- `del` - Deletes cache with key :del
- `llen` - Get length of a list with key :llen and save result in :target
- `rpush` - Appends a value :source in a list with key :rpush
- `rpushnx` - Appends a value :source in a list with key :rpush only with key not exists. This operation uses red lock;
- `hset` - Set hash with key in :hset, field from : field and value from :source
- `hget` - Get a value into :target from a hash field with :hget key
- `sadd` - Adds one or more members from :sadd to a set :source
- `sismember` - Determine if a :source value is a member of a set :sismember and save in :target
- `smembers` - Get all members from :smembers key and put in :target
- `scard` - Get number of members of set :scard and put in :target
- `rpop` - Removes and get last element from list :rpop and save in :target
- `lpop` - Removes and get first element from list :lpop and save in :target
- `lget` Get all elements from a list :lget and save in :target

Get Sample:

```ruby
filter {
    rediss {
        host => "redis.company.com"
        port => 6379
        db => 0
        password => "authtoken"
        get => "[data][id]"
        target => "[data][result]"
    }
}
```

Set with TTL Sample:

```ruby
filter {
    rediss {
        host => "redis.company.com"
        port => 6379
        db => 0
        password => "authtoken"
		ttl => 300
        setex => "[data][id]"
        source => "[data][content]"
    }
}
```

## Developing

For further instructions on howto develop on logstash plugins, please see the documentation of the official [logstash-filter-example](https://github.com/logstash-plugins/logstash-filter-example#developing).
