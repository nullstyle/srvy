module Srvy
  module Formatters
    autoload :Base,     "srvy/formatters/base"
    autoload :HostPort, "srvy/formatters/host_port"
    autoload :Dalli,    "srvy/formatters/dalli"

    def self.from_name(name)
      case name.to_sym
      when :host_port ; HostPort.new
      when :dalli ;     Dalli.new
      else ;            raise ArgumentError, "Unknown formatter name: #{name}"
      end
    end

    def self.format_single(format_name, result)
      from_name(format_name).format_single(result)
    end

    def self.format_many(format_name, result)
      from_name(format_name).format_many(result)
    end
  end
end
