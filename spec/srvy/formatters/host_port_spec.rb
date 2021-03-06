require 'spec_helper'

describe Srvy::Formatters::HostPort, "format_single" do
  Given(:host)      { Srvy::Host.new("test01.host.com", 11211, 0, 0, 100) }

  When(:result){ subject.format_single(host) }

  Then{ expect(result).to eq("test01.host.com:11211") }
end


describe Srvy::Formatters::HostPort, "format_many" do
  Given(:hosts)      { [Srvy::Host.new("test01.host.com", 11211, 0, 0, 100)] * 2 }

  When(:result){ subject.format_many(hosts) }

  Then{ expect(result).to eq(["test01.host.com:11211", "test01.host.com:11211"]) }
end