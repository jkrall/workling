#
#  Run the job over the spawn plugin. Refer to the README for instructions on 
#  installing Spawn. 
#
#  Spawn forks the entire process once for each job. This means that the job starts 
#  with a very low latency, but takes up more memory for each job. 
# 
#  It's also possible to configure Spawn to start a Thread for each job. Do this
#  by setting
#
#      Workling::Clients::SpawnClient.options = { :method => :thread }
#
#  Have a look at the Spawn README to find out more about the characteristics of this. 
#
module Workling
  module Clients
    class SpawnClient < Workling::Clients::Base

      def self.installed?
        begin
          require 'spawn'
        rescue LoadError
        end

        Object.const_defined? "Spawn"
      end

      cattr_writer :options
      def self.options
        # use thread for development and test modes. easier to hunt down exceptions that way.
        @@options ||= { :method => (RAILS_ENV == "test" || RAILS_ENV == "development" ? :fork : :thread) }
      end

      include Spawn if installed?

      def dispatch(clazz, method, options = {})
        spawn(SpawnClient.options) do # exceptions are trapped in here. 
          Workling.find(clazz, method).dispatch_to_worker_method(method, options)
        end

        return nil # that means nothing!
      end

    end
  end
end
