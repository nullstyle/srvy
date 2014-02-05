require 'spec_helper'

describe Srvy::Result do
  Given(:now)         { Time.at(Time.now.to_i) } # round to nearest second so jruby stops complaining on boundary cases
  Given(:ttl)         { 100 }
  Given(:call_count)  { 10000 }
  Given(:allowance)   { 0.02 }

  # different hosts definitions
  Given(:hosts_with_equal_weight) { [
    Srvy::Host.new("test01.host.com", 11211, 10,  0, ttl),
    Srvy::Host.new("test02.host.com", 11211, 10,  0, ttl),
  ] }

  Given(:hosts_with_unequal_weight) { [
    Srvy::Host.new("test01.host.com", 11211, 30,  0, ttl),
    Srvy::Host.new("test02.host.com", 11211, 10,  0, ttl),
  ] }

  Given(:hosts_with_unequal_priorities) { [
    Srvy::Host.new("test01.host.com", 11211, 10,  0, ttl),
    Srvy::Host.new("test02.host.com", 11211, 10,  1, ttl),
  ] }
  Given(:no_hosts) { [ ] }


  describe "#expired?" do


    context "with data" do
      subject{ Srvy::Result.new(now, hosts_with_equal_weight) }

      Then{ Timecop.freeze(now)             { expect(subject).to_not be_expired } }
      Then{ Timecop.freeze(now + ttl)       { expect(subject).to_not be_expired } }
      Then{ Timecop.freeze(now + ttl + 1)   { expect(subject).to be_expired     } }
      Then{ Timecop.freeze(now - ttl)       { expect(subject).to_not be_expired } }
      Then{ Timecop.freeze(now - (ttl + 1)) { expect(subject).to_not be_expired } }
    end

    context "with no data" do
      subject{ Srvy::Result.new(now, []) }

      Then{ Timecop.freeze(now)       { expect(subject).to_not be_expired } }
      Then{ Timecop.freeze(now + 10)  { expect(subject).to_not be_expired } }
      Then{ Timecop.freeze(now + 11)  { expect(subject).to be_expired     } }
      Then{ Timecop.freeze(now - 10)  { expect(subject).to_not be_expired } }
      Then{ Timecop.freeze(now - 11)  { expect(subject).to_not be_expired } }
    end
  end

  describe "#from_dns" do
    subject{ Srvy::Result.from_dns(dns_result) }

    Given(:dns_result) { Net::DNS::Resolver.new(:nameservers => "8.8.8.8").search("_xmpp-server._tcp.gmail.com", Net::DNS::SRV) }
    Given(:srvs)       { dns_result.answer.select{|rr| rr.is_a?(Net::DNS::RR::SRV) }}
    Given(:dns_hosts)  { srvs.map(&:host).sort }
    Given(:srvys)      { subject.get_all }
    Given(:srvy_hosts) { srvys.map(&:host).sort }

    Then{ expect(subject).to be_kind_of(Srvy::Result) }
    Then{ expect(srvy_hosts).to eq(dns_hosts) }


    Then do
      srvys.each do |srvy|
        dns = srvs.find{|d| d.host == srvy.host}

        expect(dns).to_not be_nil

        expect(srvy.host).to      eq(dns.host)
        expect(srvy.port).to      eq(dns.port)
        expect(srvy.weight).to    eq(dns.weight)
        expect(srvy.priority).to  eq(dns.priority)
      end
    end
  end


  describe "#get_many" do
    subject{ Srvy::Result.new(Time.now, hosts) }

    When(:result){ subject.get_many }

    context "hosts with equal priorities" do
      Given(:hosts) { hosts_with_equal_weight.sort_by(&:host) }
      Then{ expect(result.sort_by(&:host)).to eq(hosts) }
    end

    context "hosts with unequal priorities" do
      Given(:hosts) { hosts_with_unequal_priorities }
      # should only have the best (i.e. lowest) priority
      Then{ expect(result).to eq([hosts[0]]) }
    end
    
    context "no hosts" do
      Given(:hosts) { no_hosts }
      Then{ expect(result).to eq([]) }
    end 
  end

  describe "#get_all" do
    subject{ Srvy::Result.new(Time.now, hosts) }

    When(:result){ subject.get_all }

    context "with some hosts" do  
      Given(:hosts) { hosts_with_unequal_priorities }
      Then{ expect(result).to eq(hosts) }
    end

    context "with no hosts" do
      Given(:hosts) { [ ] }
      Then{ expect(result).to eq(hosts) }
    end
  end

  describe "#get_single" do
    subject{ Srvy::Result.new(Time.now, hosts) }

    When(:result_percentages) do 
      calls = call_count.times.map{ subject.get_single }
      
      result_counts = calls.each_with_object({}) do |call_result, acc|
        acc[call_result] ||= 0
        acc[call_result] += 1
      end
      all_hosts_and_results = result_counts.keys | hosts
      all_hosts_and_results.each_with_object({}) do |host, acc|
        count = result_counts[host] || 0
        acc[host] = count / call_count.to_f
      end
    end

    context "When the result has hosts with equal weights" do
      Given(:hosts){ hosts_with_equal_weight }

      Then do
        result_percentages.values.each do |percentage|
          expect(percentage).to be_within(allowance).of(0.5)
        end
      end 
    end

    context "hosts with unequal priority" do
      Given(:hosts){ hosts_with_unequal_priorities }

      Then do
        expect(result_percentages[hosts[0]]).to be_within(allowance).of(1.0)
        expect(result_percentages[hosts[1]]).to be_within(allowance).of(0.0)
      end 
    end


    context "hosts with unequal weights" do
      Given(:hosts){ hosts_with_unequal_weight }

      Then do
        expect(result_percentages[hosts[0]]).to be_within(allowance).of(0.75)
        expect(result_percentages[hosts[1]]).to be_within(allowance).of(0.25)
      end 
    end

    context "no hosts" do
      Given(:hosts){ no_hosts }

      Then do
        expect(result_percentages[nil]).to be_within(allowance).of(1.0)
      end 
    end
  end
end







