require 'spec_helper'

describe Srvy::Resolver do
  describe "cache setting" do
    Given(:host)   {  "google.com"}

    When{ subject.get host }

    Then{ expect(subject.cache).to have_key(host) }

  end

  describe "cache usage" do

    Given(:host)        { "google.com"}
    Given(:srvy_result) { Srvy::Result.new(Time.now, [Srvy::Host.new("test01.host.com", 11211, 10,  0, 100)])  }

    Given               { subject.cache[host] = srvy_result }

    When(:result){ subject.get host }

    Then{ expect(result).to eq(srvy_result) }

  end
end