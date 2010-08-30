require File.dirname(__FILE__) + '/../test_helper'

context "dispatching jobs" do
  specify "should dispatch calls to async_* to Workling::Remote" do
    Workling::Remote.expects(:run).with("Util", "echo", "content")
    Util.async_echo("content")
  end

  specify "should dispatch calls to asynch_* to Workling::Remote" do
    Workling::Remote.expects(:run).with("Util", "echo", "content")
    Util.asynch_echo("content")
  end
end
