module Workling
  module Clients
    class BackgroundjobClient < Workling::Clients::Base

      def self.installed?
        Object.const_defined? "Bj"
      end

      #  passes the job to bj by serializing the options to xml and passing them to
      #  ./script/bj_invoker.rb, which in turn routes the deserialized args to the
      #  appropriate worker. 
      def dispatch(clazz, method, options = {})
        stdin = Workling::Remote.routing.queue_for(clazz, method) + 
                " " + 
                options.to_xml(:indent => 0, :skip_instruct => true)
                
        Bj.submit "./script/runner ./script/bj_invoker.rb", 
          :stdin => stdin
        
        return nil # that means nothing!
      end

    end
  end
end