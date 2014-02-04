# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'srvy/version'

Gem::Specification.new do |spec|
  spec.name          = "srvy"
  spec.version       = Srvy::VERSION
  spec.authors       = ["Scott Fleckenstein"]
  spec.email         = ["nullstyle@gmail.com"]
  spec.description   = %q{SRV-based service discovery}
  spec.summary       = %q{SRV-based service discovery}
  spec.homepage      = "https://github.com/nullstyle/srvy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "net-dns",        "~> 0.8.0"
  spec.add_dependency "lru_redux",      "~> 0.8.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"

  spec.add_development_dependency "rspec",        ">= 2.14.1"
  spec.add_development_dependency "rspec-given",  ">= 3.5.0"
  spec.add_development_dependency "coveralls",    "~> 0.7.0"
end
