#! /usr/bin/env ruby
# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "SymDesc/Version"

Gem::Specification.new do |spec|
  spec.name = "SymDesc"
  spec.version = SymDesc::VERSION
  spec.authors = ["Massimiliano Dal Mas"]
  spec.email = ["max.codeware@gmail.com"]

  spec.summary = %q{Minimal computer algebra system for symbolic manipulation}
  spec.description = %q{Simple and basic computer algebra system for symbolic manipulation}
  spec.homepage = "https://max-codeware.github.io/SymDesc"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
          "public gem pushes."
  end

  spec.files = Dir["lib/**/*.rb", "test/*.rb"]
  spec.extra_rdoc_files = ["README.md", "Rakefile"]
  spec.required_ruby_version = ">= 2.5.0"
  spec.require_paths = ["lib"]
  # spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", ">= 12.3.3"
end
