require File.dirname(__FILE__) + '/../../test_helper'

context "The SQS client" do

  setup do
    @sqs = mock('sqs')
    RightAws::SqsGen2.expects(:new).at_least(1).returns(@sqs)

    Workling.send :class_variable_set, "@@config", {
      :sqs_options => {
        'aws_access_key_id' => '1234567890987654321',
        'aws_secret_access_key' => 'AbcdeFg1234567890hIJklmnOPQ12345678',
        'prefix' => 'foo_'
      }
    }
    
    @client = Workling::Clients::SqsClient.new
    @client.stubs(:logger).returns(stub_everything('logger'))
    @client.stubs(:env).returns('test')
    @client.connect
  end
  
  context "when connecting" do

    specify "should load its config from RAILS_ENV/config/workling.yml" do
      @client.sqs_options['aws_access_key_id'].should == '1234567890987654321'
      @client.sqs_options['aws_secret_access_key'].should == 'AbcdeFg1234567890hIJklmnOPQ12345678'
      @client.sqs_options['prefix'].should == 'foo_'
    end
  
    specify "should set appropriate default values for optional settings" do
      @client.messages_per_req.should == 10
      @client.visibility_timeout.should == 30
    end

  end
  
  context "when requesting work" do

    specify "should send message to correct queue" do
      params = {:foo => 'bar', :num => 42}
      queue = mock('queue')
      queue.expects(:send_message).with(params.to_json)
      @client.expects(:queue_for_key).with('my_key').returns(queue)
      
      @client.request('my_key', params)
    end

  end
  
  context "when retrieving work" do

    specify "should retrieve messages from correct queue and return first one" do
      msgs = [
        mock('msg1', :body => '{"foo":"bar", "num":42}', :received_at => Time.now, :delete => nil),
        mock('msg2', :body => '{"foo":"bar2", "num":99}', :received_at => Time.now, :delete => nil)
      ]
      queue = mock('queue')
      queue.expects(:receive_messages).with(10, 30).returns(msgs)
      @client.expects(:queue_for_key).with('my_key').returns(queue)
      
      msg = @client.retrieve('my_key')
      msg[:foo].should == 'bar'
      msg[:num].should == 42
      
      msg = @client.retrieve('my_key')
      msg[:foo].should == 'bar2'
      msg[:num].should == 99
    end

    specify "should drop messages if close to the visibility timeout" do
      msgs = [
        mock('msg1', :body => '{"foo":"bar", "num":42}', :received_at => Time.now - 15, :delete => nil),
        stub('msg2', :body => '{"foo":"bar2", "num":99}', :received_at => Time.now - 28, :delete => nil)
      ]
      queue = mock('queue')
      queue.expects(:receive_messages).with(10, 30).returns(msgs)
      @client.expects(:queue_for_key).with('my_key').returns(queue)
      
      msg = @client.retrieve('my_key')
      msg[:foo].should == 'bar'
      msg[:num].should == 42
      
      msg = @client.retrieve('my_key')
      msg.should == nil
    end
    
  end
  
  context "when generating queue names" do
    
    specify "should construct queue name from prefix, env, and key" do
      @client.queue_name('my_key').should == 'foo_test_my_key'
    end
    
    specify "should truncate to 80 characters" do
      @client.queue_name("my_key#{'x' * 100}").should == "foo_test_my_key#{'x' * 65}"
    end
    
  end
  
  context "when getting queues" do
    
    specify "should return thread local queue if it exists" do
      queue = mock('queue')
      Thread.current["queue_my_key"] = queue
      
      @client.queue_for_key('my_key').should == queue
    end
    
    specify "should create queue if thread local queue does not exist" do
      Thread.current["queue_my_key"] = nil
      queue = mock('queue')
      @sqs.expects(:queue).with('foo_test_my_key', true, 30).returns(queue)
      
      @client.queue_for_key('my_key').should == queue
    end
    
  end
  
end