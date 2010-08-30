# Cron script designed to clean up workling return queues every 5 minutes
#
# Add the following to /etc/cron.d/starling_cleanup:
# */5 * * * * root /path/to/ruby /path/to/cleanup_return_queues.rb > /dev/null 2>&1
#
require 'rubygems'
require 'memcache'

MAX_AGE = 600 # 10 minutes
SPOOL_DIR = "/var/spool/starling/"

# Connect to the starling queue
@client = MemCache.new('localhost:22122')

Dir[File.join(SPOOL_DIR, '*:*:*')].each do |file|
  queue_name = File.basename(file)

  # Skip unless it matches the format of a qorkling return queue
  next unless queue_name =~ /^\w*:\w*:[0-9a-f]/i

  # Check to see if the queue is old enough and delete it
  if(File.mtime(file) <= (Time.now - MAX_AGE))
    # Delete the queue from starling
    @client.delete(queue_name)

    # Make sure the file has been removed (it won't if the queue isn't active)
    begin
      File.delete(file) if File.exist?(file)
    rescue Exception => e
      #puts "Unable to remove: #{file} - #{e.message}"
    end
  end
end

# Close the socket to starling
@client.reset
