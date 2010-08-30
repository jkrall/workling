plugin_test = File.dirname(__FILE__)
plugin_root = File.join plugin_test, '..'
plugin_lib = File.join plugin_root, 'lib'

require 'rubygems'
#require 'active_support'

gem 'activerecord'
require 'active_record'

require 'test/spec'
require 'mocha'
begin; require 'redgreen'; rescue; end

$:.unshift plugin_lib, plugin_test

unless defined?(RAILS_ENV)
  RAILS_ENV = "test"
  RAILS_ROOT = File.dirname(__FILE__) + "/.." # fake the rails root directory.
  RAILS_DEFAULT_LOGGER = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/../test.log")
end

require "mocks/spawn"
require "mocks/logger"
require "mocks/rude_queue"

require File.join(File.dirname(__FILE__), "../lib/workling")


# worklings are in here.
Workling.load_path = ["#{ plugin_root }/test/workers/**/*.rb"]
Workling::Discovery.discover!

# make this behave like production code
Workling.raise_exceptions = false
