#
#  All worker classes must inherit from this class, and be saved in app/workers. 
# 
#  The Worker lifecycle: 
#    The Worker is loaded once, at which point the instance method 'create' is called. 
#
#  Invoking Workers: 
#    Calling async_my_method on the worker class will trigger background work.
#    This means that the loaded Worker instance will receive a call to the method
#    my_method(:uid => "thisjobsuid2348732947923"). 
#
#    The Worker method must have a single hash argument. Note that the job :uid will
#    be merged into the hash. 
#
module Workling
  class Base

    cattr_writer :logger
    def self.logger
      @@logger ||= defined?(RAILS_DEFAULT_LOGGER) ? ::RAILS_DEFAULT_LOGGER : Logger.new($stdout)
    end

    def logger
      self.class.logger
    end

    cattr_accessor :exposed_methods
    @@exposed_methods ||= {}

    def self.inherited(subclass)
      Workling::Discovery.add_worker subclass
    end

    # expose a method using a custom queue name
    def self.expose(method, options)
      self.exposed_methods[method.to_s] = options[:as]
    end

    # identify the queue for a given method
    def self.queue_for(method)
      if self.exposed_methods.has_key?(method)
        self.exposed_methods[method]
      else
        "#{ self.to_s.tableize }/#{ method }".split("/").join("__") # Don't split with : because it messes up memcache stats
      end
    end

    # identify the method linked to the queue
    def self.method_for(queue)
      if self.exposed_methods.invert.has_key?(queue)
        self.exposed_methods.invert[queue]
      else
        queue.split("__").last
      end
    end

    def method_for(queue)
      self.class.method_for(queue)
    end


    def initialize
      super
      
      create
    end

    # Put worker initialization code in here. This is good for restarting jobs that
    # were interrupted.
    def create
    end

    # override this if you want to set up exception notification
    def notify_exception(exception, method, options)
      logger.error "WORKLING ERROR: runner could not invoke #{ self.class }:#{ method } with #{ options.inspect }. error was: #{ exception.inspect }\n #{ exception.backtrace.join("\n") }"
    end

    # takes care of suppressing remote errors but raising Workling::WorklingNotFoundError
    # where appropriate. swallow workling exceptions so that everything behaves like remote code.
    # otherwise StarlingRunner and SpawnRunner would behave too differently to NotRemoteRunner.
    def dispatch_to_worker_method(method, options = {})
      begin
        options = default_options.merge(options)
        self.send(method, options)
      rescue Workling::WorklingError => e
        raise e
      rescue Exception => e
        notify_exception e, method, options

        # reraise after logging. the exception really can't go anywhere in many cases. (spawn traps the exception)
        raise e if Workling.raise_exceptions?
      end
    end    

    # supply default_options as a hash in classes that inherit Workling::Base
    def default_options
      {}
    end
  
    # thanks to blaine cook for this suggestion.
    def self.method_missing(method, *args, &block)
      if method.to_s =~ /^asynch?_(.*)/
        Workling::Remote.run(self.to_s.dasherize, $1, *args)
      else
        super
      end
    end

  end
end
