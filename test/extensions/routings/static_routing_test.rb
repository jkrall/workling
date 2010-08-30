require File.dirname(__FILE__) + '/../../test_helper'

context "static routing" do
  specify "should create an instance of the specified worker class" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#")
    routing['utils__echo'].class.should.equal Util
  end 

  specify "should return the correct method name" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#")
    routing.method_name.should.equal "echo"
  end
  
  specify "should return the correct method name for any queue passed in" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#")
    routing.method_name("any_queue").should.equal "echo"
  end  
  
  specify "should return the correct routing key" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#")
    routing.routing_key_for.should.equal "#"
  end
  
  specify "should return the correct queue name" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#")
    routing.queue_for.should.equal "utils__echo__#"
  end 
  
  specify "should return the correct queue name for the class and method" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#")
    routing.queue_for("Util", "echo").should.equal "utils__echo__#"
  end 
  
  specify "should return the correct queue name for any class and method" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#")
    routing.queue_for("foo", "bar").should.equal "utils__echo__#"
  end
  
  specify "should return an array containing a single queue name" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#")
    routing.queue_names.should.equal ["utils__echo__#"]
  end  
end

context "static routing with explicit queue name" do
  specify "should return the correct queue name" do
    routing = Workling::Routing::StaticRouting.new("Util", "echo", "#", "my.queue.name")
    routing.queue_for.should.equal "my.queue.name"
  end
end
