require File.dirname(__FILE__) + '/../../test_helper'

context "class and method routing" do
  specify "should create a queue called utils:echo for a Util class that subclasses worker and has the method echo" do
    routing = Workling::Routing::ClassAndMethodRouting.new  
    routing['utils__echo'].class.to_s.should.equal "Util"
  end
  
  specify "should create a queue called analytics:invites:sent for an Analytics::Invites class that subclasses worker and has the method sent" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing['analytics__invites__sent'].class.to_s.should.equal "Analytics::Invites"
  end
  
  specify "queue_names_routing_class should return all queue names associated with a class" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing.queue_names_routing_class(Util).should.include 'utils__echo'
  end

  specify "attached queue should return subscription key when given class" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing.queue_names_routing_class(Util).should.include 'my very_own queue'
  end

  specify "attached queue should return class when given the subscription key" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing['my very_own queue'].class.to_s.should.equal "Util"
  end

  specify "queue_name should be properly parsed for an unexposed method" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing.method_name('utils__echo').should == 'echo'
  end

  specify "queue_name should be properly looked up for an exposed method" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing.method_name('my very_own queue').should == 'very_open'
  end

  specify "exposed method should should be registered by its queue" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing.queue_for(Util, 'very_open').should == 'my very_own queue'
  end

  specify "unexposed methods should be registered by their computed name" do
    routing = Workling::Routing::ClassAndMethodRouting.new
    routing.queue_for(Util, 'echo').should == 'utils__echo'
  end
end


