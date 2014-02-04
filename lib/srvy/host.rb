require 'net/dns'
require 'lru_redux'

module Srvy
  class Host

    attr_reader :host
    attr_reader :port
    attr_reader :weight
    attr_reader :priority
    attr_reader :ttl

    def initialize(host, port, weight, priority, ttl)
      @host     = host
      @port     = port
      @weight   = weight
      @priority = priority
      @ttl      = ttl
    end
  end
end