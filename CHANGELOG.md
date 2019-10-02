## 1.0.4
 - Support for GET, HGET, SET, HSET, SETEX, EXISTS, DEL, SADD, SMEMBERS, SISMEMBER and SCARD;
 - Support SSL (redis or rediss protocol);
 - Support TTL (when you uses SETEX);
 - Introduce new control field `cmd_key_is_formatted` for declaring commands
   to be resolved through - see %{foo} handling;
 - Introduce optional configuration options for controlling the count and
   the interval of retries - see :max_retries, :lock_retry_interval and
   :max_lock_retries;
