require File.dirname(__FILE__) + '/../../test_helper'

context "The memcachequeue client" do
  setup do
    Workling.config = {}
    Workling::Clients::AmqpClient.load
    @client = Workling::Clients::AmqpClient.new
    @mq = prepare_mq
    @client.connect
  end

  def prepare_mq
    AMQP.stubs(:start)
    mq = stub(:mq)
    MQ.stubs(:new).returns(mq)
    mq
  end

  specify "publishing an item" do
    @mq.expects(:queue).with("queue_key").returns(mock(:publish))
    @client.request("queue_key", :value)
  end

  specify "subscribing to a queue" do
    @mq.expects(:queue).with("queue_key").returns(mock(:subscribe))
    @client.subscribe("queue_key")
  end


  specify "publishing an item with a prefix" do
    Workling.config[:prefix] = "myapp_"
    @mq.expects(:queue).with("myapp_queue_key").returns(mock(:publish))
    @client.request("queue_key", :value)
  end

  specify "subscribing to a queue with a prefix" do
    Workling.config[:prefix] = "myapp_"
    @mq.expects(:queue).with("myapp_queue_key").returns(mock(:subscribe))
    @client.subscribe("queue_key")
  end
end
