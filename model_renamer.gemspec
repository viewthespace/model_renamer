# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'model_renamer/version'

Gem::Specification.new do |spec|
  spec.name          = "model_renamer"
  spec.version       = ModelRenamer::VERSION
  spec.authors       = ["Paul Gut"]
  spec.email         = ["pg@vts.com"]
  spec.homepage      = "https://github.com/viewthespace/model_renamer"
  spec.summary       = "Renames any ActiveRecord model and generates database migrations"
  spec.description   = "The model renamer gem allows you to rename any a model in your rails application. The gem looks for occurrences of any variation or pluralization of the old model name and changes it to the corresponding variation of the new name. It also generates database migrations that rename tables and foreign keys referencing the old name."
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
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "memfs"
  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"
  spec.add_dependency "rails"
end
