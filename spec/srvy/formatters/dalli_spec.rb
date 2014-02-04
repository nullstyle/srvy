require 'spec_helper'

describe Srvy::Formatters::Dalli, "format_single" do
  Given(:host) { Srvy::Host.new("test01.host.com", 11211, 10, 0, 100) }

  When(:result){ subject.format_single(host) }

  Then{ expect(result).to eq("test01.host.com:11211:10") }
end


describe Srvy::Formatters::Dalli, "format_many" do
  Given(:hosts) { [
    Srvy::Host.new("test01.host.com", 11211, 10, 0, 100),
    Srvy::Host.new("test02.host.com", 11211, 5,  0, 100),
  ] }

  When(:result){ subject.format_many(hosts) }

  Then{ expect(result).to eq(["test01.host.com:11211:10", "test02.host.com:11211:5"]) }
end