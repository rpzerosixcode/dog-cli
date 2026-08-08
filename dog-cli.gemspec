# frozen_string_literal: true

require_relative "lib/dog/version"

Gem::Specification.new do |spec|
  spec.name = "dog-cli"
  spec.version = Dog::VERSION
  spec.authors = ["Ruan Pablo Dos Santos Gonçalves"]
  spec.email = ["rp.zerosix.code@gmail.com"]

  spec.summary = "CLI to fetch random dog images"
  spec.description = "Command line tool that fetches random dog images using the Dog CEO API."
  spec.homepage = "https://github.com/rpzerosixcode/dog-cli"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("lib/**/*") + %w[LICENSE README.md ARCHITECTURE.md CHANGELOG.md exe/dog]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "net-http", "~> 0.9"
  spec.add_dependency "thor", "~> 1.3"
end
