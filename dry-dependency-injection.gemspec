lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dry/dependency_injection/version"

Gem::Specification.new do |spec|
  spec.name          = "dry-dependency-injection"
  spec.version       = Dry::DependencyInjection::VERSION
  spec.authors       = [""]
  spec.email         = [""]
  spec.summary       = "add dependency injection to dry-container"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mkristian/dry-dependency-injection"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_runtime_dependency "concurrent-ruby", "~> 1.0"
  spec.add_runtime_dependency "dry-container", "~> 0.6"
  spec.add_runtime_dependency "dry-core", "~> 0.4"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "dry-auto_inject", "~> 0.4"
  spec.add_development_dependency "dry-inflector", "~> 0.4"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.4"
end
