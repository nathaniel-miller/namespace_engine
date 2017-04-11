# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_namespace_engine/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_namespace_engine"
  spec.version       = RailsNamespaceEngine::VERSION
  spec.authors       = ["Nathaniel Miller"]
  spec.email         = ["nathaniel@m.ller.io"]

  spec.summary       = %q{Generate a rails engine with an extra layer of namespacing.}
  spec.description   = %q{This script runs the rails plugin generator. It then changes the directory structure and file contents (based on provided namespacing and engine name) to prevent potential collisions with other engines.}
  spec.homepage      = "https://github.com/nathaniel-miller/namespace_engine/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables << 'namespace_engine'
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rails", "~> 3.0"
end
