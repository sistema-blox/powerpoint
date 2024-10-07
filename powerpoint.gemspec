# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "powerpoint/version"

Gem::Specification.new do |spec|
  spec.name          = "powerpoint"
  spec.version       = Powerpoint::VERSION
  spec.authors       = ["pythonicrubyist", "saleszera"]
  spec.email         = ["pythonicrubyist@gmail.com", "raniery@saleszera.com"]
  spec.description   = "A Ruby gem that can create a PowerPoint presentation."
  spec.summary       = "powerpoint is a Ruby gem that can create a PowerPoint presentation based on a standard pptx template."
  spec.homepage      = "https://github.com/sistema-blox/powerpoint"
  spec.license       = "MIT"

  spec.files         = %x(git ls-files).split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6.0"

  spec.add_development_dependency("pry")
  spec.add_development_dependency("pry-byebug")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec", "~> 3.13")
  spec.add_development_dependency("rubocop", "~> 1.18")
  spec.add_development_dependency("rubocop-performance", "~> 1.11")
  spec.add_development_dependency("rubocop-rake", "~> 0.6")
  spec.add_development_dependency("rubocop-rspec", "~> 2.0")
  spec.add_development_dependency("rubocop-shopify", "~> 2.15")
  spec.add_development_dependency("shoulda-matchers", "~> 6.4")

  spec.add_dependency("fastimage", "~> 2.3")
  spec.add_dependency("rubyzip", "~> 2.3")
end
