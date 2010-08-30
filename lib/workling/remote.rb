require 'digest/md5'

#
#  Scoping Module for Runners. 
#
module Workling
  module Remote

    # which object to use for routing
    mattr_writer :routing
    def self.routing
      @@routing ||= Workling::Routing::ClassAndMethodRouting.new
    end

    # which client to use for dispatching
    mattr_accessor :client
    def self.client
      @@client ||= Workling.select_and_build_client
    end

    # generates a unique identifier for this particular job. 
    def self.generate_uid(clazz, method)
      uid = ::Digest::MD5.hexdigest("#{ clazz }:#{ method }:#{ rand(1 << 64) }:#{ Time.now }")
      "#{ clazz.to_s.tableize }/#{ method }/#{ uid }".split("/").join(":")
    end

    # dispatches to a workling. writes the :uid for this work into the options hash, so make 
    # sure you pass in a hash if you want write to a return store in your workling.
    def self.run(clazz, method, options = {})
      uid = Workling::Remote.generate_uid(clazz, method)
      options[:uid] = uid if options.kind_of?(Hash) && !options[:uid]
      Workling.find(clazz, method) # this line raises a WorklingError if the method does not exist.
      client.dispatch(clazz, method, options)
      uid
    end

  end
end
