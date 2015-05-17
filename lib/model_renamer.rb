require "model_renamer/version"

#!/usr/bin/env ruby

require 'find'
require 'fileutils'
require 'active_support'
require 'active_record'
require 'model_renamer/migration_generator.rb'
require 'model_renamer/variations_generator.rb'
require 'model_renamer/model_renamer_runner.rb'








# ModelRenamer.new(ARGV[0], ARGV[1]).replace_and_generate_migration

