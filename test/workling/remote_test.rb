require File.dirname(__FILE__) + '/../test_helper'

context "remote dispatcher" do
  setup do
    @client = stub(:dispatch => nil)
    Workling::Remote.client = @client
  end

  specify "should dispatch a job to the client" do
    @client.expects(:dispatch).with("Util", "echo", "hello")
    Workling::Remote.run("Util", "echo", "hello")
  end

  specify "should generate and return uid if options is a hash" do
    @client.expects(:dispatch).with("Util", "echo", has_entry(:uid => 'uid'))
    Workling::Remote.stubs(:generate_uid).returns('uid')
    assert_equal 'uid', Workling::Remote.run("Util", "echo", { :prompt => "hello" })
  end

  specify "should raise WorklingError if worker class does not exist" do
    should.raise Workling::WorklingNotFoundError do
      Workling::Remote.run(:quatsch_mit_sosse, :fiddle_di_liddle)
    end
  end

  specify "should raise WorklingError if method does not exist on the worker class" do
    should.raise Workling::WorklingNotFoundError do
      Workling::Remote.run(:util, :sau_sack)
    end
  end
end
