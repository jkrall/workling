require File.dirname(__FILE__) + '/integration_setup'

class IntegrationSetupRecorder

  def initialize(name)
    @name = name
  end

  # recorders
  def guard(&block)
    @guard = block
  end

  def setup_each(&block)
    @setup_each = block
  end

  def teardown_each(&block)
    @teardown_each = block
  end

  def run_daemon
    @run_daemon = true
  end

  def dispatcher(dispatcher)
    @dispatcher = dispatcher
  end

  def client(client)
    @client = client
  end

  def invoker(invoker)
    @invoker = invoker
  end

  def config(&block)
    @config = block
  end

  # convenience methods
  def tmp_directory
    IntegrationSetup.tmp_directory
  end

  # output
  def build_setup
    IntegrationSetup.new @name,
                         :guard => @guard,
                         :config => @config,
                         :setup_each => @setup_each,
                         :teardown_each => @teardown_each,
                         :run_daemon => @run_daemon,
                         :dispatcher => @dispatcher,
                         :client => @client,
                         :invoker => @invoker
  end

end
