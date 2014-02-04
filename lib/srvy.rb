require "srvy/version"
require "net/dns/ext/resolver_nameserver_monkey_patch"

module Srvy
  autoload :Resolver, "srvy/resolver"
  autoload :Result,   "srvy/result"
  autoload :Host,     "srvy/host"

  autoload :Formatters, "srvy/formatters"
end
