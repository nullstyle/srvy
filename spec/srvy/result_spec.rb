require 'spec_helper'

describe Srvy::Result, "#expired?" do
  subject{ Srvy::Result.new(now, hosts) }

  Given(:hosts) { [
    Srvy::Host.new("test01.host.com", 11211, 10, 0, ttl),
    Srvy::Host.new("test02.host.com", 11211, 5,  0, ttl),
  ] }
  Given(:now){ Time.now }
  Given(:ttl){ 100 }


  Then{ Timecop.freeze(now)             { expect(subject).to_not be_expired } }
  Then{ Timecop.freeze(now + ttl)       { expect(subject).to_not be_expired } }
  Then{ Timecop.freeze(now + ttl + 1)   { expect(subject).to be_expired     } }
  Then{ Timecop.freeze(now - ttl)       { expect(subject).to_not be_expired } }
  Then{ Timecop.freeze(now - (ttl + 1)) { expect(subject).to_not be_expired } }
end


describe Srvy::Result, "get_many" do
  subject{ Srvy::Result.new(Time.now, hosts) }

  Given(:hosts) { [
    Srvy::Host.new("test01.host.com", 11211, 0,  0, 100),
    Srvy::Host.new("test02.host.com", 11211, 0,  1, 100),
  ] }

  When(:result){ subject.get_many }
  # should only have the best (i.e. lowest) priority
  Then{ expect(result).to eq([hosts[0]]) }
end


describe Srvy::Result, "get_all" do
  subject{ Srvy::Result.new(Time.now, hosts) }

  Given(:hosts) { [
    Srvy::Host.new("test01.host.com", 11211, 0,  0, 100),
    Srvy::Host.new("test02.host.com", 11211, 0,  1, 100),
  ] }

  When(:result){ subject.get_all }

  Then{ expect(result).to eq(hosts) }
end

describe Srvy::Result, "get_single" do
  subject{ Srvy::Result.new(Time.now, hosts) }

  Given(:hosts_with_equal_weight) { [
    Srvy::Host.new("test01.host.com", 11211, 10,  0, 100),
    Srvy::Host.new("test02.host.com", 11211, 10,  0, 100),
  ] }

  Given(:hosts_with_unequal_weight) { [
    Srvy::Host.new("test01.host.com", 11211, 30,  0, 100),
    Srvy::Host.new("test02.host.com", 11211, 10,  0, 100),
  ] }

  Given(:hosts_with_unequal_priorities) { [
    Srvy::Host.new("test01.host.com", 11211, 10,  0, 100),
    Srvy::Host.new("test02.host.com", 11211, 10,  1, 100),
  ] }

  Given(:call_count) { 10000 }
  Given(:allowance)  { 0.01 }


  When(:result_percentages) do 
    calls = call_count.times.map{ subject.get_single }
    
    result_counts = calls.each_with_object({}) do |call_result, acc|
      acc[call_result] ||= 0
      acc[call_result] += 1
    end
    hosts.each_with_object({}) do |host, acc|
      count = result_counts[host] || 0
      acc[host] = count / call_count.to_f
    end
  end

  context "When the result has hosts with equal weights" do
    Given(:hosts){ hosts_with_equal_weight }

    # should only have the best (i.e. lowest) priority
    Then do
      result_percentages.values.each do |percentage|
        expect(percentage).to be_within(allowance).of(0.5)
      end
    end 
  end

  context "When the result has hosts with unequal priority" do
    Given(:hosts){ hosts_with_unequal_priorities }

    # should only have the best (i.e. lowest) priority
    Then do
      expect(result_percentages[hosts[0]]).to be_within(allowance).of(1.0)
      expect(result_percentages[hosts[1]]).to be_within(allowance).of(0.0)
    end 
  end


  context "When the result has hosts with unequal weights" do
    Given(:hosts){ hosts_with_unequal_weight }

    # should only have the best (i.e. lowest) priority
    Then do
      expect(result_percentages[hosts[0]]).to be_within(allowance).of(0.75)
      expect(result_percentages[hosts[1]]).to be_within(allowance).of(0.25)
    end 
  end
end