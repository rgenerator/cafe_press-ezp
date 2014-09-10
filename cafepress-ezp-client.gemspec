# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cafepress/ezp/client/version'

Gem::Specification.new do |spec|
  spec.name          = "cafepress-ezp-client"
  spec.version       = CafePress::EZP::Client::VERSION
  spec.authors       = ["relentlessGENERATOR"]
  spec.email         = ["dev@rgenerator.com"]
  spec.summary       = %q{CafePress EZ Prints API Client}
  spec.description   = %q{}
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "builder"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
