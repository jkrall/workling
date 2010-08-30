require File.dirname(__FILE__) + '/../../test_helper'

context "the invoker 'thread pool poller'" do
  setup do
    @routing = Workling::Routing::ClassAndMethodRouting.new
    @client = Workling::Clients::MemoryQueueClient.new
    @client.connect
    @invoker = Workling::Invokers::ThreadPoolPoller.new(@routing, @client.class)
  end

  specify "should have default values for various settings" do
    @invoker.sleep_time.should.equal 2.0
    @invoker.reset_time.should.equal 30.0
    @invoker.pool_capacity.should.equal 25
  end

  specify "should pull configuration values from the workling global config" do
    Workling.stubs(:config).returns(
      :sleep_time => 10, :reset_time => '45', :pool_size  => '50'
    )

    @invoker = Workling::Invokers::ThreadPoolPoller.new(@routing, @client.class)

    @invoker.sleep_time.should.equal 10.0
    @invoker.reset_time.should.equal 45.0
    @invoker.pool_capacity.should.equal 50
  end

  specify "should work in general" do
    # Assumptions
    Workling::Discovery.discovered_workers.size.should.not.be 0

    mock_client do |client|
      client.expects(:retrieve).at_least_once.returns(nil)
      client.expects(:retrieve).with('utils__echo').returns({ :uid => '1234'}, nil)
    end

    @invoker.expects(:run).once.with('utils__echo', { :uid => '1234' })

    should.not.raise do
      Timeout.timeout(10) do
        with_running_invoker do
          sleep 0.5 # noop
        end
      end
    end

    @invoker.poller_threads.should.be(0)
    @invoker.worker_threads.should.be(0)
  end

  specify "should not retrieve any items from the backing queue if no workers are available" do
    mock_client do |client|
      client.expects(:retrieve).never
    end

    @invoker.stubs(:workers_available?).returns(false)

    with_running_invoker do
      @invoker.worker_threads.should.be 0
      sleep 0.5
    end
  end

  specify "should reset connection on memcache failure" do
    mock_client do |client|
      client.stubs(:retrieve)
      client.expects(:retrieve).with('utils__echo').raises(Workling::WorklingConnectionError)
      client.expects(:reset)
    end

    # Stub out sleep so tests don't take forever
    @invoker.stubs(:sleep)
    @invoker.expects(:sleep).with(30.0)

    with_running_invoker do
      sleep 0.5
    end
  end

  private
  def with_running_invoker(&block)
    listener = Thread.new { @invoker.listen }

    # Wait until the invoker has finished starting
    while(@invoker.poller_threads != Workling::Discovery.discovered_workers.size)
      Thread.pass
    end

    yield

    @invoker.stop
    listener.join
  end

  def mock_client(&block)
    client = mock()
    client.stubs(:connect)

    yield client

    @client.class.expects(:new).times(Workling::Discovery.discovered_workers.size).returns(client)
  end
end
