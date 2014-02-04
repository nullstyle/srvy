module Srvy
  module Formatters
    class Base

      def format_single(host)
        raise NotImplementedError
      end

      def format_many(hosts)
        # default to mapping over the collection with the format_single form
        # by having a separate format_many call, we can build formatters
        # that aggregate results in some way (such as producing a map of the hosts)
        hosts.map{|h| format_single h}
      end
    end
  end
end
