require 'spec_helper'
require 'orm/models/basic'

describe "attribute methods" do
  before do
    @model = Basic.new :foo => :bar
  end

  it "should define reader method" do
    @model.foo.should == :bar
  end

  it "should define writer method" do
    @model.foo = :foo
    @model.foo.should == :foo
  end

  it "should be possible to write attributes" do
    @model.write_attribute :foo, "baaaaar"
    @model.foo.should == "baaaaar"
  end

  it "should be possible to read attributes" do
    @model.read_attribute(:foo).should == :bar
  end

  describe "#attributes=" do
    it "should simply return if incomming value is not a hash" do
      @model.attributes = "FOO => BAR"
      @model.attributes.keys.should include("foo")
    end
  end
end
