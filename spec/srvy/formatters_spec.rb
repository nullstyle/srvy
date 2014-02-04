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