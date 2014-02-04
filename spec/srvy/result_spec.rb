require 'spec_helper'

describe Srvy::Result, "#expired?" do
  Given(:hosts) { [
    Srvy::Host.new("test01.host.com", 11211, 10, 0, ttl),
    Srvy::Host.new("test02.host.com", 11211, 5,  0, ttl),
  ] }

  Given(:now){ Time.now }
  Given(:ttl){ 100 }

  subject{ Srvy::Result.new(now, hosts) }

  Then{ Timecop.freeze(now)             { expect(subject).to_not be_expired } }
  Then{ Timecop.freeze(now + ttl)       { expect(subject).to_not be_expired } }
  Then{ Timecop.freeze(now + ttl + 1)   { expect(subject).to be_expired     } }
  Then{ Timecop.freeze(now - ttl)       { expect(subject).to_not be_expired } }
  Then{ Timecop.freeze(now - (ttl + 1)) { expect(subject).to_not be_expired } }
end