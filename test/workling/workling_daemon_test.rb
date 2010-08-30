require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/workling_daemon'


context "splitting between daemon and workling options" do
  specify "it should split the args array at the separator" do
    WorklingDaemon.partition_options(["start", "--", "--environment=production"]).should == [["start"], ["--environment=production"]]
  end

  specify "it should only return daemon options if they only exist" do
    WorklingDaemon.partition_options(["start"]).should == [["start"], []]
  end

  specify "it should only return workling options if they only exist" do
    WorklingDaemon.partition_options(["--", "--environment=production"]).should == [[], ["--environment=production"]]
  end
end

context "parsing daemon options" do
  specify "should parse -a option" do
    WorklingDaemon.parse_daemon_options(["-a", "my_app_name"]).should == {:app_name => "my_app_name", :ARGV => []}
  end

  specify "should parse --app_name option" do
    WorklingDaemon.parse_daemon_options(["--app-name=my_app_name"]).should == {:app_name => "my_app_name", :ARGV => []}
  end

  specify "should parse -m option" do
    WorklingDaemon.parse_daemon_options(["-m"]).should == {:monitor => true, :ARGV => []}
  end

  specify "should parse --monitor option" do
    WorklingDaemon.parse_daemon_options(["--monitor"]).should == {:monitor => true, :ARGV => []}
  end

  specify "should pass through start, stop, restart, run, zap commands" do
    %W{start stop restart run zap}.each do |command|
      WorklingDaemon.parse_daemon_options([command]).should == {:ARGV => [command]}
    end
  end

  specify "should passthrough the -t, --ontop, -f, --force, -h, --help and --version options" do
    %W{-t --ontop -f --force -h --help --version}.each do |option|
      WorklingDaemon.parse_daemon_options([option]).should == {:ARGV => [option]}
    end
  end


  specify "should parse a command line including both Daemons options and custom daemon_options" do
    WorklingDaemon.parse_daemon_options(["start", "-t", "-a", "my_app_name"]).should == {:ARGV => ["start", "-t"], :app_name => "my_app_name"}
  end


  specify "should ignore workling options" do
    WorklingDaemon.parse_daemon_options(["start", "--", "--environment=production"]).should == {:ARGV => ["start"]}
  end
end

context "parsing workling options" do
  specify "should parse the -p option" do
    WorklingDaemon.parse_workling_options(["--", "-p", "myapp"]).should == {:prefix => "myapp"}
  end

  specify "should parse the --prefix option" do
    WorklingDaemon.parse_workling_options(["--", "--prefix=myapp"]).should == {:prefix => "myapp"}
  end

  specify "should parse the -c option" do
    WorklingDaemon.parse_workling_options(["--", "-c", "memcache"]).should == {:client => "memcache"}
  end

  specify "should parse the --client option" do
    WorklingDaemon.parse_workling_options(["--", "--client=memcache"]).should == {:client => "memcache"}
  end


  specify "should parse the -i option" do
    WorklingDaemon.parse_workling_options(["--", "-i", "looped"]).should == {:invoker => "looped"}
  end

  specify "should parse the --invoker option" do
    WorklingDaemon.parse_workling_options(["--", "--invoker=looped"]).should == {:invoker => "looped"}
  end


  specify "should parse the -r option" do
    WorklingDaemon.parse_workling_options(["--", "-r", "class_and_method"]).should == {:routing => "class_and_method"}
  end

  specify "should parse the --routing option" do
    WorklingDaemon.parse_workling_options(["--", "--routing=class_and_method"]).should == {:routing => "class_and_method"}
  end


  specify "should parse the -l option" do
    WorklingDaemon.parse_workling_options(["--", "-l", "/var/www/current/app/workers"]).should == {:load_path => "/var/www/current/app/workers"}
  end

  specify "should parse the --load-path option" do
    WorklingDaemon.parse_workling_options(["--", "--load-path=/var/www/current/app/workers"]).should == {:load_path => "/var/www/current/app/workers"}
  end


  specify "should parse the -e option" do
    WorklingDaemon.parse_workling_options(["--", "-e", "production"]).should == {:rails_env => "production"}
  end

  specify "should parse the --environment option" do
    WorklingDaemon.parse_workling_options(["--", "--environment=production"]).should == {:rails_env => "production"}
  end


  specify "should ignore daemon options" do
    WorklingDaemon.parse_workling_options(["start", "--", "--environment=production"]).should == {:rails_env => "production"}
  end
end

context "configuring daemon" do
  context "load path setting" do
    specify "it should overwrite default load path if given on the command line" do
      WorklingDaemon.initialize_workling :load_path => "/some/where/else"
      Workling.load_path.should == "/some/where/else"
    end

    specify "it not overwrite default load path it is not given" do
      load_path = Workling.load_path
      WorklingDaemon.initialize_workling({})
      Workling.load_path.should == load_path
    end
  end

  specify "it should discover worklings" do
    Workling::Discovery.expects(:discover!).once
    WorklingDaemon.initialize_workling({})
  end

  context "loading config" do
    specify "it should load config file if config_path is given" do
      WorklingDaemon.initialize_workling :config_path => "/this/is/my/config_file"
      
    end

    specify "it should take config from command line if config_path is not given" do
      WorklingDaemon.initialize_workling :client => "sqs", :invoker => "basic_poller", :routing => "class_and_method"
      Workling.config[:client].should == "sqs"
      Workling.config[:invoker].should == "basic_poller"
      Workling.config[:routing].should == "class_and_method"
    end
  end
end
