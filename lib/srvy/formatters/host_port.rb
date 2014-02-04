module Srvy
  module Formatters
    class HostPort < Base

      def format_single(host)
        "#{host.host}:#{host.port}"
      end
      
    end
  end
end
