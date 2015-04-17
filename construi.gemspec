# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'construi/version'

Gem::Specification.new do |spec|
  spec.name          = "construi"
  spec.version       = Construi::VERSION
  spec.authors       = ["lstephen"]
  spec.email         = ["levi.stephen@gmail.com"]
  spec.summary       = %q{Build tool using Docker to specify build environment}
  spec.description   = %q{Build tool using Docker to specify build environment}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 1.9'

  spec.add_dependency 'docker-api', '~> 1.20'
  spec.add_dependency 'colorize', '~> 0.7.5'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'gem-release', '~> 0.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
end
