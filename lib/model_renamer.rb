require "model_renamer/version"

#!/usr/bin/env ruby

require 'find'
require 'fileutils'
require 'active_support'
require 'active_support/inflector'
require 'active_record'
require 'rails/generators'
require 'model_renamer/migration_generator'
require 'model_renamer/variations_generator'
require 'model_renamer/rename'




