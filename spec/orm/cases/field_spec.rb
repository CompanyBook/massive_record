require 'spec_helper'

describe "field" do
  before do
    @subject = MassiveRecord::ORM::Field.new(:status)
    @subject.column_family = :info
  end
  
  it "should have a name made of column_family and column" do
    @subject.name.should == "info:status"
  end
  
  it "should have a column family name" do
    @subject.column_family.should == :info
  end
  
  it "should have a column name" do
    @subject.column.should == :status
  end
  
  it "should default the type to string" do
    @subject.type == :string
  end
  
  it "should set the default value to nil" do
    @subject.default.should be_nil
  end
  
  it "should accept 2 arguments" do
    @subject = MassiveRecord::ORM::Field.new(:status, :boolean)
    @subject.column.should == :status
    @subject.type.should == :boolean
    @subject.default.should be_nil
  end
  
  it "should accept 3 arguments" do
    @subject = MassiveRecord::ORM::Field.new(:status, :boolean, { :default => false })
    @subject.column.should == :status
    @subject.type.should == :boolean
    @subject.default.should be_false
  end
end
