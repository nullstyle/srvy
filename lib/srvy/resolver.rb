require "net/dns/ext/resolver_nameserver_monkey_patch"
require 'lru_redux/has_key_monkey_patch'

module Srvy
  class Resolver
    attr_reader :cache

    def initialize(options={})
      @dns       = Net::DNS::Resolver.new

      if options[:nameserver]
        @dns.nameservers = options[:nameserver] 
      end

      cache_size = options[:cache_size] || 100
      @cache     = LruRedux::Cache.new(cache_size) #cache of host -> result kv pairs
    end

    def inspect
      "#<Srvy::Resolver:#{object_id} dns=#{@dns.nameservers.inspect}>"
    end

    def get_single(host, format=:host_port)
      result = get(host).get_single

      Srvy::Formatters.format_single(format, result)
    end

    def get_many(host, format=:host_port)
      result = get(host).get_many
      Srvy::Formatters.format_many(format, result)
    end

    def get_all(host, format=:host_port)
      result = get(host).get_all
      Srvy::Formatters.format_many(format, result)
    end

    def get_dns(host)
      @dns.search(host, Net::DNS::SRV)
    end

    # Gets the Srvy::Result from the cache or from dns.
    #
    # host  - The String hostname to query for SRV records.
    #
    #
    # Returns the Srvy::Result for that hostname
    def get(host)
      result = @cache[host]

      if !result || result.expired?
        result = Srvy::Result.from_dns get_dns(host)
        @cache[host] = result
      end
     
      result
    end

  end
end