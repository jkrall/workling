require 'eventmachine'

#
#  Subscribes the workers to the correct queues. 
# 
module Workling
  module Invokers
    class EventmachineSubscriber < Workling::Invokers::Base
      
      def initialize(routing, client_class)
        super
      end
      
      #
      #  Starts EM loop and sets up subscription callbacks for workers. 
      #
      def listen
        EM.run do
          connect do
            routes.each do |route|
              @client.subscribe(route) do |args|
                begin
                  run(route, args)
                rescue
                  logger.error("EventmachineSubscriber listen error on #{route}: #{$!}")
                end
              end
            end
          end
        end
      end
              
      def stop
        EM.stop if EM.reactor_running?
      end
    end
  end
end
