require 'spec_helper'
require 'orm/models/basic'

describe "finders" do
  describe "#find" do
    it "should have at least one argument" do
      lambda { Basic.find }.should raise_error ArgumentError
    end
  end

  %w(first last all).each do |method|
    it "should respond to #{method}" do
      Basic.should respond_to method
    end

    it "should delegate #{method} to find with first argument as :#{method}" do
      Basic.should_receive(:find).with(method.to_sym)
      Basic.send(method)
    end

    it "should delegate #{method}'s call to find with it's args as second argument" do
      options = {:foo => :bar}
      Basic.should_receive(:find).with(anything, options)
      Basic.send(method, options)
    end
  end
end
