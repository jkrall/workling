module Workling
  module Clients
    class BrokerBase < Base

      #
      # Dispatch a job to the client. If this client uses a job broker, then
      # this method should submit it, otherwise it should run the job
      #
      #    clazz: Name of the worker class
      #    method: Name of the methods on the worker
      #    options: optional arguments for the job
      #
      def dispatch(clazz, method, options = {})
        @connected ||= connect
        request(Workling::Remote.routing.queue_for(clazz, method), options)
        return nil
      end


      #
      #  Requests a job on the broker.
      #
      #      work_type: 
      #      arguments: the argument to the worker method
      #
      def request(work_type, arguments)
        raise NotImplementedError.new("Implement request(work_type, arguments) in your client. ")
      end    

      #
      #  Gets job results off a job broker. Returns nil if there are no results. 
      #
      #      worker_uid: the uid returned by workling when the work was dispatched
      #
      def retrieve(work_uid)
        raise NotImplementedError.new("Implement retrieve(work_uid) in your client. ")
      end
      
      #
      #  Subscribe to job results in a job broker.
      #
      #      worker_type: 
      #
      def subscribe(work_type)
        raise NotImplementedError.new("Implement subscribe(work_type) in your client. ")
      end
      
      #
      #  Opens a connection to the job broker.
      #
      def connect
        raise NotImplementedError.new("Implement connect() in your client. ")
      end
      
      #
      #  Closes the connection to the job broker. 
      #
      def close
        raise NotImplementedError.new("Implement close() in your client. ")
      end
    end
  end
end
