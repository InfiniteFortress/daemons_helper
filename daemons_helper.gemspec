# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daemons_helper/version'

Gem::Specification.new do |spec|
  spec.name          = "daemons_helper"
  spec.version       = DaemonsHelper::VERSION
  spec.authors       = ["Ferris Lucas"]
  spec.email         = ["ferris.lucas@gmail.com"]
  spec.description   = %q{helper for daemons gem}
  spec.summary       = %q{provides a base class so your code is easily separated from the plumbing associated with running your code using the super awesome daemons gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "daemons"
  spec.add_development_dependency "yell"
  spec.add_development_dependency "eventmachine"
  spec.add_development_dependency "subtle"
  spec.add_development_dependency "ekg"

  spec.add_runtime_dependency "daemons"
  spec.add_runtime_dependency "yell"
  spec.add_runtime_dependency "eventmachine"
  spec.add_runtime_dependency "subtle"
  spec.add_runtime_dependency "ekg"
end