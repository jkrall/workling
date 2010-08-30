require 'eventmachine'

#
# TODO - Subscribes a single worker to a single queue 
# 
module Workling
  module Invokers
    class AmqpSingleSubscriber < Workling::Invokers::Base

      def initialize(routing, client_class)
        super
      end

      #
      # Starts EM loop and sets up subscription callback for the worker
      # Create the queue and bind to exchange using the routing key
      #
      def listen
        EM.run do
          connect do
            queue_name = @routing.queue_for
            routing_key = @routing.routing_key_for
      
            # temp stuff to hook the queues and exchanges up
            # wildcard routing - # (match all)
            exch = MQ.topic
            q = MQ.queue(queue_name)
            q.bind(exch, :key => routing_key)
      
            @client.subscribe(queue_name) do |args|
              run(queue_name, args)
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