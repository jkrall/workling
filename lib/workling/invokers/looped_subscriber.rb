#
#  Subscribes the workers to the correct queues. 
# 
module Workling
  module Invokers
    class LoopedSubscriber < Workling::Invokers::Base
    
      def initialize(routing, client_class)
        super
      end
    
      #
      #  Starts EM loop and sets up subscription callbacks for workers. 
      #
      def listen
        connect do
          routes.each do |route|
            @client.subscribe(route) do |args|
              run(route, args)
            end
          end
    
          loop do
            sleep 1
          end
        end
      end
    
      def stop
        
      end
    end
  end
end
