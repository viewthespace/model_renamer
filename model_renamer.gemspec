# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'model_renamer/version'

Gem::Specification.new do |spec|
  spec.name          = "model_renamer"
  spec.version       = ModelRenamer::VERSION
  spec.authors       = ["Paul Gut"]
  spec.email         = ["pg@vts.com"]
  spec.homepage      = "https://rubygems.org/gems/model_renamer"
  spec.summary       = "Renames any model"
  spec.description   = "A gem that renames your ActiveRecord models and generates corresponding migrations"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
