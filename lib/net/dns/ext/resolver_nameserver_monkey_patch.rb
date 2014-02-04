require 'net/dns'

Net::DNS::Resolver.class_eval do
  def nameservers=(arg)
    @config[:nameservers] = convert_nameservers_arg_to_ips(arg)
    @logger.info "Nameservers list changed to value #{@config[:nameservers].inspect}"
  end

  private
  def convert_nameservers_arg_to_ips(arg)
    case arg
    when IPAddr ; [arg]
    when String ;
      begin
      [IPAddr.new(arg)]
      rescue ArgumentError # arg is in the name form, not IP
        nameservers_from_name(arg)
      end
    when Array ;
      arg.map{|x| convert_nameservers_arg_to_ips(x) }.flatten
    else
      raise ArgumentError, "Wrong argument format, neither String, Array nor IPAddr"
    end
  end

  def nameservers_from_name(arg)
    arr = []
    arg.split(" ").each do |name|
      Net::DNS::Resolver.new.search(name).each_address do |ip|
        arr << ip
      end
    end
    arr
  end

end
