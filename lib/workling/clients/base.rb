#
#  Clients are responsible for dispatching jobs either to a broker (starling, rabbitmq etc) or invoke them (spawn)
#
#  Clients that involve a broker should subclass Workling::Clients::BrokerBase
#
#  Clients are used to request jobs on a broker, get results for a job from a broker, and subscribe to results
#  from a specific type of job. 
#
module Workling
  module Clients
    class Base

      #
      # Load the required libraries, for this client
      #
      def self.load
        
      end


      #
      # See if the libraries required for this client are installed
      #
      def self.installed?
        true
      end


      # returns the Workling::Base.logger
      def logger; Workling::Base.logger; end


      #
      # Dispatch a job to the client. If this client uses a job broker, then
      # this method should submit it, otherwise it should run the job
      #
      #    clazz: Name of the worker class
      #    method: Name of the methods on the worker
      #    options: optional arguments for the job
      #
      def dispatch(clazz, method, options = {})
        raise NotImplementedError.new("Implement dispatch(clazz, method, options) in your client. ")
      end


      #
      #  Requests a job on the broker.
      #
      #      work_type: 
      #      arguments: the argument to the worker method
      #
      def request(work_type, arguments)
        raise WorklingError.new("This client does not involve a broker.")
      end

      #
      #  Gets job results off a job broker. Returns nil if there are no results. 
      #
      #      worker_uid: the uid returned by workling when the work was dispatched
      #
      def retrieve(work_uid)
        raise WorklingError.new("This client does not involve a broker.")
      end
      
      #
      #  Subscribe to job results in a job broker.
      #
      #      worker_type: 
      #
      def subscribe(work_type)
        raise WorklingError.new("This client does not involve a broker.")
      end
      
      #
      #  Opens a connection to the job broker.
      #
      def connect
        raise WorklingError.new("This client does not involve a broker.")
      end
      
      #
      #  Closes the connection to the job broker. 
      #
      def close
        raise WorklingError.new("This client does not involve a broker.")
      end
    end
  end
end
