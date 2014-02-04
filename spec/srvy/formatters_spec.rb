require 'spec_helper'

describe Srvy::Formatters, "#from_name" do
  
  context "with an invalid name" do
    Given(:name){ "some_formatter" }
    When(:result) { Srvy::Formatters.from_name(name) }
    Then { expect(result).to have_failed(ArgumentError, /Unknown/) }
  end


  context "with host_port" do
    Given(:name){ "host_port" }
    When(:result) { Srvy::Formatters.from_name(name) }
    Then { expect(result).to be_kind_of(Srvy::Formatters::HostPort) }
  end
end

describe Srvy::Formatters, "#format_single" do
  Given(:formatter) { double("Formatter", :format_single => true)}
  Given(:name)      { "host_port" }
  Given(:host)      { Srvy::Host.new("test01.host.com", 11211, 0, 0, 100) }
  Given             { Srvy::Formatters.stub(:from_name){ formatter } }

  When(:result) { Srvy::Formatters.format_single(name, host) }

  Then{ expect(formatter).to have_received(:format_single).with(host) }
end


describe Srvy::Formatters, "#format_many" do
  Given(:formatter) { double("Formatter", :format_many => true)}
  Given(:name)      { "host_port" }
  Given(:hosts)     { [Srvy::Host.new("test01.host.com", 11211, 0, 0, 100)] }
  Given             { Srvy::Formatters.stub(:from_name){ formatter } }

  When(:result) { Srvy::Formatters.format_many(name, hosts) }

  Then{ expect(formatter).to have_received(:format_many).with(hosts) }
end