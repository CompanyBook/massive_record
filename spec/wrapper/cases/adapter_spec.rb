require 'spec_helper'

describe "The Massive Record adapter" do
  
  it "should default to thrift" do
    MassiveRecord.adapter.should == :thrift
  end

end
