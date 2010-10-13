require 'optparse'

class WorklingDaemon

  def self.partition_options(args)
    daemon = []
    workling = []
    split_point = args.index("--") || args.size
    daemon = args[0...split_point] if split_point > 0
    workling = args[(split_point+1)..-1] if split_point and split_point < args.size
    [daemon, workling]
  end

  def self.partition_daemons_options(args)
    standard_options = %W{start stop restart run zap -t --ontop -f --force -h --help --version}
    pass_through = args.select { |a| standard_options.include? a }
    custom_options = args.reject { |a| standard_options.include? a }

    [pass_through, custom_options]
  end

  def self.parse_daemon_options(argv)
    options = {}
    pass_through, args = partition_daemons_options argv
    opts = OptionParser.new do |opts|
      opts.banner = 'Usage: myapp [options]'
      opts.separator ''
      opts.on('-a', '--app-name APP_NAME', String,"specify the process name") { |v| options[:app_name] = v }
      opts.on('-d', '--dir DIR', String, "the directory to run in") { |v| options[:dir] = v }
      opts.on('-m', '--monitor',"specify the process name") { |v| options[:monitor] = true }
      opts.on('-M', '--multiple',"allow multiple workers") { |v| options[:multiple] = true }
      opts.on('-t', '--ontop') { |k, v| pass_through << v  }
    end
    opts.parse!(partition_options(args).first)
    options.merge(:ARGV => pass_through)
  end

  def self.parse_workling_options(args)
    options = {}
    opts = OptionParser.new do |opts|
      opts.banner = 'Usage: myapp [options]'
      opts.separator ''
      opts.on('-n', '--no_rails', "do not load Rails") { |v| options[:no_rails] = true }
      opts.on('-c', '--client CLIENT', String, "specify the client class") { |v| options[:client] = v }
      opts.on('-i', '--invoker INVOKER', String, "specify the invoker class") { |v| options[:invoker] = v }
      opts.on('-r', '--routing ROUTING', String, "specify the routing class") { |v| options[:routing] = v }
      opts.on('-l', '--load-path LOADPATH', String, "specify the load_path for the workers") { |v| options[:load_path] = v }
      opts.on('-f', '--config-path CONFIGPATH', String, "specify the path to the workling.yml file") { |v| options[:config_path] = v }
      opts.on('-e', '--environment ENVIRONMENT', String, "specify the environment") { |v| options[:rails_env] = v }
      opts.on('-p', '--prefix PREFIX', String, "specify the prefix for queues") { |v| options[:prefix] = v }
    end
    opts.parse!(partition_options(args).last)
    options
  end

  def self.extract_options(options)
    result = {}
    result[:client] = options[:client] if options[:client]
    result[:routing] = options[:routing] if options[:routing]
    result[:invoker] = options[:invoker] if options[:invoker]
    result
  end

  def self.initialize_workling(options)
    Workling.load_path = options[:load_path] if options[:load_path]
    Workling::Discovery.discover!

    if options[:config_path]
      Workling.config_path = options[:config_path]
      Workling.config
    else
      Workling.config = extract_options options
    end

    Workling.select_and_build_invoker
  end

  def self.boot_with(options)
    ENV['WORKLING_DAEMON'] = '1'
    if options[:no_rails]
      # if rails is not booted we need to pull in the workling requires manually
      require File.join(File.dirname(__FILE__), "workling")
    else
      ENV["RAILS_ENV"] = options[:rails_env]
      puts "=> Loading Rails with #{ENV["RAILS_ENV"]} environment..."
      require options[:rails_root] + '/config/environment'

      ActiveRecord::Base.logger = Workling::Base.logger
      ActionController::Base.logger = Workling::Base.logger

      puts '** Rails loaded.'
    end
  end


  def self.run(options)
    boot_with options
    poller = initialize_workling(options)

    puts "** Starting #{ poller.class }..."
    puts '** Use CTRL-C to stop.'

    trap(:INT) { poller.stop; exit }

    begin
      poller.listen
    ensure
      puts '** No Worklings found.' if Workling::Discovery.discovered_workers.empty?
      puts '** Exiting'
    end
  end

end
