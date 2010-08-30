#
#  An Ampq client
#
module Workling
  module Clients
    class AmqpExchangeClient < Workling::Clients::BrokerBase

      def self.load
        begin
          require 'mq'
        rescue Exception => e
          raise WorklingError.new(
            "WORKLING: couldn't find the ruby amqp client - you need it for the amqp runner. " \
            "Install from github: gem sources -a http://gems.github.com/ && sudo gem install tmm1-amqp "
          )
        end
      end

      # starts the client. 
      def connect
        begin
          @amq = MQ.new
        rescue
          raise WorklingError.new("couldn't start amq client. if you're running this in a server environment, then make sure the server is evented (ie use thin or evented mongrel, not normal mongrel.)")
        end
      end

      # no need for explicit closing. when the event loop
      # terminates, the connection is closed anyway. 
      def close; true; end

      # subscribe to a queue
      def subscribe(key)
        @amq.queue(key).subscribe do |header, body|
          value = YAML.load(body)
          yield value
        end
      end

      # request and retrieve work
      def retrieve(key)
          @amq.queue(key)
      end

      # publish message to exchange
      # using the specified routing key
      def request(exchange_name, value)
        exchange_name = "amq.topic"

        key = value.delete(:routing_key)
        msg = YAML.dump(value)
        exchange = @amq.topic(exchange_name)
        exchange.publish(msg, :routing_key => key)
      end

    end
  end
end
