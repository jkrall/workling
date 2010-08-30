require File.dirname(__FILE__) + '/../integration_helper'

$setup_loader.each_setup do |setup|

  context "Basic Operation for #{setup.name}" do

    setup do
      setup.setup_test
    end

    teardown do
      setup.teardown_test
    end


    specify "should execute async operation" do
      BasicOperationWorker.async_do_work(:token => "my magic token")
      sleep(2)     # this is not clean, but we need to wait for the async call to finish

      File.exists?(File.join(setup.tmp_directory, "basic_operation.output")).should == true
      File.read(File.join(setup.tmp_directory, "basic_operation.output")).should == "my magic token"
    end

  end

end
