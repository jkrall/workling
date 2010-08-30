#
#  Spawns a Thread. Used for Tests only, to simulate a remote runner more realistically. 
#
module Workling
  module Clients
    class ThreadClient < Workling::Clients::Base

      def dispatch(clazz, method, options = {})
        Thread.new {
          Workling.find(clazz, method).dispatch_to_worker_method(method, options)
        }

        return nil
      end

    end
  end
end
