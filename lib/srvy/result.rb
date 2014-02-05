require 'net/dns'
require 'lru_redux'

module Srvy
  class Result
    

    def self.from_dns(dns_result)
      # for each SRV record
      srvs = dns_result.answer.select{|rr| rr.is_a?(Net::DNS::RR::SRV) }
      hosts = srvs.map do |srv|
        Srvy::Host.new(srv.host, srv.port, srv.weight, srv.priority, srv.ttl)
      end

      new(Time.now, hosts)
    end

    def initialize(created_at, hosts)
      @created_at = created_at
      @hosts      = hosts
    end

    def get_single
      roll = rand(best_priority_cumulative_weight)
      acc = 0

      best_priority_hosts_by_weight.each do |host|
        acc += host.weight
        return host if roll < acc
      end
    end

    def get_many
      best_priority_hosts_by_weight
    end

    def get_all
      @hosts
    end

    def expired?
      now = Time.now
      @hosts.any?{|s| @created_at + s.ttl < now}
    end

    private
    def best_priority_hosts_by_weight
      # sorted weight descending
      best_priority_hosts_by_weight ||= @hosts.select{|s| s.priority <= best_priority }.sort_by(&:weight).reverse
    end

    def best_priority_cumulative_weight
      best_priority_hosts_by_weight.map(&:weight).inject(0, :+)
    end

    def best_priority
      @best_priority ||= @hosts.map(&:priority).min
    end
  end
end