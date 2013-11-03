# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitmessage/version'

Gem::Specification.new do |spec|
  spec.name          = "bitmessage"
  spec.version       = Bitmessage::VERSION
  spec.authors       = ["Adam Thorsen"]
  spec.email         = ["awt@fastmail.fm"]
  spec.description   = %q{This gem provides an client library for the PyBitmessage API.}
  spec.summary       = %q{This gem allows listing, sending, generating, etc messages via the Bitmessage protocol.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
