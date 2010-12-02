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
end
