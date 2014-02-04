module Srvy
  module Formatters
    class Dalli < Base

      def format_single(host)
        "#{host.host}:#{host.port}:#{host.weight}"
      end
      
    end
  end
end
