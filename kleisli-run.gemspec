# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kleisli/run/version'

Gem::Specification.new do |spec|
  spec.name          = "kleisli-run"
  spec.version       = Kleisli::Run::VERSION
  spec.authors       = ["Brian Zeligson"]
  spec.email         = ["brian.zeligson@gmail.com"]
  spec.summary       = %q{do notation for monads provided by the Kleisli gem}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_runtime_dependency "kleisli-validation"
end
