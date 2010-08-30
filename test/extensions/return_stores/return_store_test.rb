require File.dirname(__FILE__) + '/../../test_helper'

context "The return store" do
  setup do
    Workling::Return::Store.instance = Workling::Return::Store::MemoryReturnStore.new
  end

  specify "should set a value on the current store when invoked like this: Workling::Return::Store.set(:key, 'value')" do
    Workling::Return::Store.set(:key, :value)
    Workling::Return::Store.get(:key).should.equal :value
  end
  
  specify "should get a value on the current store when invoked like this: Workling::Return::Store.get(:key)" do
    Workling::Return::Store.set(:key, :value)
    Workling::Return::Store.get(:key).should.equal :value 
  end
  
  specify "should set a value on the current store when invoked like this: Workling.return.set(:key, 'value')" do
    Workling.return.set(:key, :value)
    Workling.return.get(:key).should.equal :value
  end
  
  specify "should return an iterator for a specific key when invoked like this: Workling.return.iterator(key)" do
    Workling::Return::Store.set(:key, 1)
    Workling::Return::Store.set(:key, 2)
    Workling.return.iterator(:key).collect{ |item| item }.should.equal [1, 2]
  end
end
