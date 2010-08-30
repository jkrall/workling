require 'thread'
require 'mutex_m'

#
# A polling invoker that executes the jobs using a thread pool.
#
# This invoker was designed for long running tasks and Rails 2.2. It is expected
# that each worker will manage it's own database connections using ActiveRecord::Base.connection_pool.
#
# This implementation isn't using most of the features provided by Invokers::Base
# because of it's assumptions about database connections
#
# Example:
#   user = nil
#   ActiveRecord::Base.connection_pool.with_connection do
#     user = User.find(options[:id])
#   end
#
#   # Do long running stuff here
#   user.wait_until_birthday
#   user.buy_gift 'BRAWNDO!'
#
#   ActiveRecord::Base.connection_pool.with_connection do
#     user.save
#   end
#
module Workling
  module Invokers
    class ThreadPoolPoller < Workling::Invokers::Base
      attr_reader :sleep_time, :reset_time, :pool_capacity
    
      def initialize(routing, client_class)
        @routing = routing
        @client_class = client_class
    
        # Grab settings out of the config file
        @sleep_time = (Workling.config[:sleep_time] || 2).to_f
        @reset_time = (Workling.config[:reset_time] || 30).to_f
    
        # Pool of polling threads
        @pollers = []
        @pollers.extend(Mutex_m)
    
        # Pool of worker threads
        @workers = []
        @workers.extend(Mutex_m)
    
        # Connection to the job queue
        @pool_capacity = (Workling.config[:pool_size] || 25).to_i
      end
    
      # Start up the checking for items on the queue. Will block until stop is called and all pollers
      # and workers have finished execution.
      def listen
        logger.info("Starting ThreadPoolPoller...")
    
        # Determine which queues need checking
        Workling::Discovery.discovered_workers.map do |klass|
          @pollers.synchronize do
            # Polls the backing queue for jobs to be done
            @pollers << Thread.new do
              poller_thread(@routing.queue_names_routing_class(klass))
            end
          end
        end
    
        # Wait for the poller and all outstanding workers to finish.
        #
        # This is a little tricky because we're doing some synchronization on pollers... but
        # the list of pollers is never modified after being setup above.
        @pollers.synchronize { @pollers.dup }.each { |p| p.join }
        @pollers.synchronize { @pollers.clear }
        logger.info("Pollers have all finished")
    
        @workers.synchronize { @workers.dup }.each { |w| w.join }
        logger.info("Worker threads have all finished")
      end
    
      # Instructs the thread pool poller to stop checking for new jobs on the backing queue.
      def stop
        logger.info("Stopping thread pool invoker pollers and workers...")
        @pollers.synchronize { @pollers.each { |p| p[:shutdown] = true } }
      end
    
      # Set pool_size in workling config to adjust the maximum number of threads in the pool
      def workers_available?
        worker_threads < @pool_capacity
      end
    
      # Number of correctly active worker threads
      def worker_threads
        @workers.synchronize { @workers.size }
      end
    
      # Number of currently active polling threads
      def poller_threads
        @pollers.synchronize { @pollers.size }
      end
    
      private
    
      def poller_thread(queues)
        # Make sure queues is an array
        queues = [queues].flatten!
    
        # Connect our client to the backing queue
        client = @client_class.new
        client.connect
        logger.info("** Starting client #{ client.class } for #{ queues.inspect }") if logger.info?
    
        # Poll each queue for new items
        while(!Thread.current[:shutdown]) do
          # Check each queue for a job posting
          queues.each do |queue|
            break if Thread.current[:shutdown]
    
            begin
              # Take a job off the queue and execute it in a new worker thread.
              #
              # Don't pop any jobs off the backing queue if the thread pool
              # is full. This keeps them on the master queue so other instances
              # can process them.
              while(workers_available? && (options = client.retrieve(queue)))
                logger.debug("#{queue} received job #{ options.inspect }") if logger.debug?
    
                @workers.synchronize do
                  @workers << Thread.new do
                    begin
                      # Execute the job
                      run(queue, options)
                    rescue Exception => e
                      # Log the exception since there isn't much else we can do about it at this point
                      logger.error(e) if logger.error?
                    ensure
                      # Make sure the current thread's connection gets released
                      if(ActiveRecord::Base.connection_pool)
                        ActiveRecord::Base.connection_pool.release_connection
                      end
    
                      # Remove this thread from the list of active workers
                      @workers.synchronize do
                        @workers.delete(Thread.current)
                      end
                    end
                  end
                end
    
                # Break out of the checks early if shutdown was called
                break if Thread.current[:shutdown]
              end
            rescue Workling::WorklingError => e
              logger.error("FAILED to connect with queue #{ queue }: #{ e } }") if logger.error?
              sleep(@reset_time)
    
              # FIXME: This will _definitely_ blow up with AMQP since there is no reset call
              client.reset
            end
          end
    
          sleep(@sleep_time) unless Thread.current[:shutdown]
        end
      end
    end
  end
end
