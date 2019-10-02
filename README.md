# Logstash Filter Rediss Plugin

[![Build Status](https://travis-ci.org/thiagobarradas/logstash-filter-rediss.svg)](https://travis-ci.org/thiagobarradas/logstash-filter-rediss)
[![Gem Version](https://badge.fury.io/rb/logstash-filter-rediss.svg)](https://badge.fury.io/rb/logstash-filter-rediss)
[![GitHub license](https://img.shields.io/github/license/thiagobarradas/logstash-filter-rediss.svg)](https://github.com/thiagobarradas/logstash-filter-rediss)

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is MIT, see [LICENSE](http://github.com/thiagobarradas/logstash-filter-rediss/LICENSE) for further infos.

## Documentation

Actions allowed:
- ``

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
