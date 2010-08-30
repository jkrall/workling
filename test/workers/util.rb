require 'workling/base'

class Util < Workling::Base
  def echo(*args)
    # shout!
  end
  
  def faulty(args)
    raise Exception.new("this is pretty faulty.")
  end
  
  def stuffing(contents)
    # expects contents. 
  end

  def broken(*args)
    raise "Broken"
  end

  cattr_reader :on_error_call_count
  @@on_error_call_count = 0
  def on_error(e)
    @@on_error_call_count += 1
  end

  expose :very_open, :as => "my very_own queue"
  def very_open(chocolate)
    
  end
end
