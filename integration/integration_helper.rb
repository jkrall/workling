require 'rubygems'

gem 'activesupport'
require 'active_support'

require 'test/spec'

RAILS_ENV = "test"
RAILS_ROOT = File.dirname(__FILE__) + "/.." # fake the rails root directory.
RAILS_DEFAULT_LOGGER = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/../test.log")

require File.join(File.dirname(__FILE__), "../lib/workling")

# worklings are in here.
Workling.load_path = [File.join(File.dirname(__FILE__), "workers/*.rb")]
Workling::Discovery.discover!

require File.dirname(__FILE__) + '/support/integration_setup_loader'

$setup_loader = IntegrationSetupLoader.build File.join(File.dirname(__FILE__), "setups")
$setup_loader.load!
