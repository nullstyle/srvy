require 'spec_helper'

describe Srvy::Formatters::Base, "format_single" do
  Given(:host)      { Srvy::Host.new("test01.host.com", 11211, 0, 0, 100) }

  When(:result){ subject.format_single(host) }

  Then { expect(result).to have_failed(NotImplementedError) }
end

