#
#  Run the job inline
#
module Workling
  module Clients
    class NotRemoteClient < Workling::Clients::Base

      def dispatch(clazz, method, options = {})
        options = Marshal.load(Marshal.dump(options)) # get this to behave more like the remote runners
        Workling.find(clazz, method).dispatch_to_worker_method(method, options)

        return nil # nada. niente.
      end

    end
  end
end
