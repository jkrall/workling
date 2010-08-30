#
#  Dont actually run the job...
#
module Workling
  module Clients
    class NotClient < Workling::Clients::Base

      def dispatch(clazz, method, options = {})
        return nil # nada. niente.
      end

    end
  end
end
