class IntegrationSetup

  attr_reader :name

  def self.tmp_directory
    File.join(File.dirname(__FILE__), "../tmp")
  end

  def tmp_directory
    self.class.tmp_directory
  end

  def self.base_directory
    File.join(File.dirname(__FILE__), "../..")
  end

  def base_directory
    self.class.base_directory
  end


  def initialize(name, options={})
    @name = name
    @options = options
  end

  def can_run?
    if @options[:guard]
      @options[:guard].call
    else
      true
    end
  end

  def setup_test
    clean_tmp_directory
    @options[:setup_each] && @options[:setup_each].call
    start_daemon if @options[:run_daemon]
    setup_environment
  end

  def teardown_test
    end_daemon if @options[:run_daemon]
    @options[:teardown_each] && @options[:teardown_each].call
    clean_tmp_directory
  end

  def setup_group
    
  end

  def teardown_group
    
  end

  private
    def clean_tmp_directory
      Dir.glob(File.join(tmp_directory, "*")).each do |f|
        File.delete f
      end
    end

    def setup_environment
      Workling.config = @options[:config].call if @options[:config]
      Workling::Remote.client = Workling.clients[@options[:client].to_s].new
    end

    def start_daemon
      `ruby #{base_directory}/bin/workling_client start -a integration_workling -d #{tmp_directory} -- -n -i #{@options[:invoker]} -c #{@options[:client]} -l #{base_directory}/integration/workers/*.rb`
    end

    def end_daemon
      `ruby #{base_directory}/bin/workling_client stop -a integration_workling -d #{tmp_directory}`
    end

end
