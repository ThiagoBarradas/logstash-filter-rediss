# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "redis"
require "redlock"

class LogStash::Filters::Rediss < LogStash::Filters::Base
    config_name "rediss"

    # The field to perform filter
    config :source, :validate => :string, :default => "message"

    # The name of the container to put the result
    config :target, :validate => :string, :default => "message"

    # The field to use in hset
    config :field, :validate => :string

    # Expire time in seconds for setex
    config :ttl, :validate => :number, :default => 60

    # Informs if the connection is to be made with SSL or not
    config :ssl, :validate => :boolean, :default => false

    # For now only working for rpushnx and llen!
    config :cmd_key_is_formatted, :validate => :boolean, :default => false

    # The hostname(s) of your Redis server(s). Ports may be specified on any
    # hostname, which will override the global port config.
    # If the hosts list is an array, Logstash will pick one random host to connect to,
    # if that host is disconnected it will then pick another.
    #
    # For example:
    # [source,ruby]
    #     "127.0.0.1"
    #     ["127.0.0.1", "127.0.0.2"]
    #     ["127.0.0.1:6380", "127.0.0.1"]
    config :host, :validate => :array, :default => ["127.0.0.1"]

    # Shuffle the host list during Logstash startup.
    config :shuffle_hosts, :validate => :boolean, :default => true

    # The default port to connect on. Can be overridden on any hostname.
    config :port, :validate => :number, :default => 6379

    # The Redis database number.
    config :db, :validate => :number, :default => 0

    # Redis initial connection timeout in seconds.
    config :timeout, :validate => :number, :default => 5

    # Password to authenticate with.  There is no authentication by default.
    config :password, :validate => :password

    # Interval for reconnecting to failed Redis connections
    config :reconnect_interval, :validate => :number, :default => 1

    # Maximal count of command retries after a crash because of a failure
    config :max_retries, :validate => :number, :default => 3

    # Interval for retrying to acquire a lock
    config :lock_retry_interval, :validate => :number, :default => 1

    # config :get, :validate => :boolean, :default => false
    config :lock_timeout, :validate => :number, :default => 5000

    # Maximal count of retries to acquire a lock
    config :max_lock_retries, :validate => :number, :default => 3

    ################# ACTIONS

    # Sets the action. If has value, this action will be executed
    # GET: get cache with key in :get and set value in :target
    config :get, :validate => :string

    # Sets the action. If has value, this action will be executed
    # SET: set cache with key in :set and value from :source
    config :set, :validate => :string

    # Sets the action. If has value, this action will be executed
    # SETEX: set cache with key in :setex, considering TTL from :ttl (in seconds) and value from :source
    config :setex, :validate => :string

    # Sets the action. If has value, this action will be executed
    # EXISTS: perform exists operation in :exists key and save result in :target
    config :exists, :validate => :string

    # Sets the action. If has value, this action will be executed
    # DEL: deletes cache with key :del
    config :del, :validate => :string

    # Sets the action. If has value, this action will be executed
    # LLEN: get length of a list with key :llen and save result in :target
    config :llen, :validate => :string

    # Sets the action. If has value, this action will be executed
    # RPUSH: aapend value :source in a list with key :rpush
    config :rpush, :validate => :string

    # Sets the action. If has value, this action will be executed
    # RPUSHNX: aapend value :source in a list with key :rpush only with key not exists
    # This operation uses red lock;
    config :rpushnx, :validate => :string

    # Sets the action. If has value, this action will be executed
    # HSET: set hash with key in :hset, field from : field and value from :source
    config :hset, :validate => :string

    # Sets the action. If has value, this action will be executed
    # HGET: get a value into :target from a hash field with :hget key
    config :hget, :validate => :string

    # Sets the action. If has value, this action will be executed
    # SADD: add one or more members from :sadd to a set :source
    config :sadd, :validate => :string

    # Sets the action. If has value, this action will be executed
    # SISMEMBER: Determine if a :source value is a member of a set :sismember and save in :target
    config :sismember, :validate => :string

    # Sets the action. If has value, this action will be executed
    # SMEMBERS: Get all members from :smembers key and put in :target
    config :smembers, :validate => :string

    # Sets the action. If has value, this action will be executed
    # SCARD: Get number of members of set :scard and put in :target
    config :scard, :validate => :string

    # Sets the action. If has value, this action will be executed
    # RPOP: Remove and get last element from list :rpop and save in :target
    config :rpop, :validate => :string

    # Sets the action. If has value, this action will be executed
    # LPOP: Remove and get first element from list :lpop and save in :target
    config :lpop, :validate => :string

    # Sets the action. If has value, this action will be executed
    # LGET: Get all elements from a list :lget and save in :target
    config :lget, :validate => :string

    public
    def register
        @redis = nil
        @lock_manager = nil
        if @shuffle_hosts
            @host.shuffle!
        end
        @host_idx = 0
    end # def register

    def filter(event)

        # TODO: Maybe refactor the interface into a more flexible one with two
        #       main configs 'cmd' & 'args'. Then it would be possible to eliminate
        #       all if clauses and replace it through one hashmap call, where
        #       the hashmap would be a mapping from 'cmd' -> <cmd_function_ref>
        #       E.q.: cmds.fetch(event.get(@llen), &method(:cmd_not_found_err))
        max_retries = @max_retries
        begin
            @redis ||= connect

            if @get
                event.set(@target, @redis.get(event.get(@get)))
            end

            if @set
                @redis.set(event.get(@set), event.get(@source))
            end

            if @setex
                @redis.setex(event.get(@setex), @ttl, event.get(@source))
            end

            if @exists
                event.set(@target, @redis.exists(event.get(@exists)))
            end

            if @del
                @redis.del(event.get(@del))
            end

            if @hget
                event.set(@target, @redis.hget(event.get(@hget), event.get(@source)))
            end

            if @hset
                @redis.hset(event.get(@hset), event.get(@field), event.get(@source))
            end

            if @sadd
                @redis.sadd(event.get(@sadd), event.get(@source))
            end

            if @sismember
                event.set(@target, @redis.sismember(event.get(@sismember), event.get(@source)))
            end

            if @smembers
                event.set(@target, @redis.smembers(event.get(@smembers)))
            end

            if @scard
                event.set(@target, @redis.scard(event.get(@scard)))
            end

            if @llen
                key = @cmd_key_is_formatted ? event.sprintf(@llen) : event.get(@llen)
                event.set(@target, @redis.llen(key))
            end

            if @rpush
                @redis.rpush(event.get(@rpush), event.get(@source))
            end

            if @rpushnx
                key = @cmd_key_is_formatted ? event.sprintf(@rpushnx) : event.get(@rpushnx)
                max_lock_retries = @max_lock_retries
                begin
                    @lock_manager ||= connect_lockmanager
                    @lock_manager.lock!("lock_#{key}", @lock_timeout) do
                        @redis.rpush(key, event.get(@source)) unless @redis.exists(key)
                    end
                rescue Redlock::LockError => e
                    @logger.warn("Failed to lock section 'rpushnx' for key: #{key}",
                                 :event => event, :exception => e)
                    sleep @lock_retry_interval
                    max_lock_retries -= 1
                    unless max_lock_retries < 0
                        retry
                    else
                        @logger.error("Max retries reached for trying to lock section 'rpushnx' for key: #{key}",
                                      :event => event, :exception => e)
                    end
                end
            end

            if @rpop
                event.set(@target, @redis.rpop(event.get(@rpop)))
            end

            if @lget
                event.set(@target, @redis.lrange(event.get(@lget), 0, -1))
            end

        rescue => e
            @logger.warn("Failed to send event to Redis, retrying after #{@reconnect_interval} seconds...", :event => event,
                         :exception => e, :backtrace => e.backtrace)
            sleep @reconnect_interval
            @redis = nil
            @lock_manager = nil
            max_retries -= 1
            unless max_retries < 0
                retry
            else
                @logger.error("Max retries reached for trying to execute a command",
                              :event => event, :exception => e)
            end
        end

        # filter_matched should go in the last line of our successful code
        filter_matched(event)
    end # def filter

    private
    def connect
        @current_host, @current_port = @host[@host_idx].split(':')
        @host_idx = @host_idx + 1 >= @host.length ? 0 : @host_idx + 1

        if not @current_port
            @current_port = @port
        end

        params = {
            :host => @current_host,
            :port => @current_port,
            :timeout => @timeout,
            :db => @db,
            :ssl => @ssl
        }

        @logger.debug("Connection params", params)

        if @password
            params[:password] = @password.value
        end

        Redis.new(params)
    end # def connect

    def connect_lockmanager
        @protocol =  @ssl ? 'rediss://' : 'redis://'

        hosts = Array(@host).map { |host|
            host.prepend(@protocol) unless host.start_with?(@protocol) 
        }

        @logger.debug("lock_manager hosts", hosts)

        Redlock::Client.new(hosts)
    end # def connect_lockmanager

end # class LogStash::Filters::Rediss
