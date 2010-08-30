require File.dirname(__FILE__) + '/../test_helper'

context "Exceptions raised by worker" do
  before do    
    @old_dispatcher = Workling::Remote.client
    Workling::Remote.client = Workling::Clients::NotRemoteClient.new
  end
  after do
    Workling::Remote.client = @old_dispatcher # set back to whence we came
  end
  
  specify "should not escape dispatcher" do
    lambda {
      Workling::Remote.run(:util, :broken)
    }.should.not.raise
  end

  specify "should call notify_exception method" do 
    Util.any_instance.expects(:notify_exception).once
    Workling::Remote.run(:util, :broken)
  end
end
