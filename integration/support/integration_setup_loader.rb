require File.dirname(__FILE__) + '/integration_setup_recorder'

class IntegrationSetupLoader

  def self.build(*args)
    @instance ||= new(*args)
  end

  def initialize(setup_dir)
    @setup_dir = setup_dir
    @setups = []
    @initialized = false
  end

  def load!
    # only setup once
    return if @initialized
    @initialized = true

    Dir.glob(File.join(@setup_dir, "*.rb")).each do |f|
      require File.join(File.dirname(f), File.basename(f, ".rb"))
    end
  end

  def register(name, &block)
    setup_recorder = IntegrationSetupRecorder.new(name)
    yield setup_recorder
    @setups << setup_recorder.build_setup
  end


  def each_setup(&block)
    @setups.select(&:can_run?).each do |setup|
      begin
        setup.setup_group
        yield setup
      ensure
        setup.teardown_group
      end
    end
  end

end
