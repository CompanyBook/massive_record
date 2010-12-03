require 'spec_helper'
require 'orm/models/basic'

describe "finders" do
  describe "#find" do
    before do
      @mocked_table = mock(MassiveRecord::Wrapper::Table).as_null_object
      Basic.stub(:table).and_return(@mocked_table)
    end

    it "should have at least one argument" do
      lambda { Basic.find }.should raise_error ArgumentError
    end

    it "should ask the table to look up by it's id" do
      @mocked_table.should_receive(:find).with(1)
      Basic.find(1)
    end

    %w(first last all).each do |method|
      it "should call table's #{method} on find(:{method})" do
        @mocked_table.should_receive(method)
        Basic.find(method.to_sym)
      end
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
