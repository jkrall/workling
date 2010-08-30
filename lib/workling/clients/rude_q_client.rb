#
#  This client interfaces with RudeQ a databased queue system
#   http://github.com/matthewrudy/rudeq
#
module Workling
  module Clients
    class RudeQClient < Workling::Clients::BrokerBase

      def self.installed?
        begin
          gem 'rudeq'
          require 'rudeq' 
        rescue LoadError
        end

        Object.const_defined? "RudeQueue"
      end

      def self.load
        begin
          gem 'rudeq'
          require 'rudeq'
        rescue Gem::LoadError
          Workling::Base.logger.info "WORKLING: couldn't find rudeq library. Install: \"gem install matthewrudy-rudeq\". "
        end
      end

      # no-op as the db connection should exists always
      def connect
      end

      # again a no-op as we would want to yank out the db connection behind the apps back
      def close
      end

      # implements the client job request and retrieval 
      def request(key, value)
        RudeQueue.set(key, value)
      end

      def retrieve(key)
        RudeQueue.get(key)
      end

    end
  end
end
