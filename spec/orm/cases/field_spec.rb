require 'spec_helper'

describe "field" do
  before do
    @subject = MassiveRecord::ORM::Field.new(:status)
    @subject.column_family = :info
  end
  
  it "should have a name made of column_family and column" do
    @subject.unique_name.should == "info:status"
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
    @subject.name.should == :status
    @subject.column.should == :status
    @subject.type.should == :boolean
    @subject.default.should be_nil
    
    @subject = MassiveRecord::ORM::Field.new(:status, { :default => "processing" })
    @subject.name.should == :status
    @subject.column.should == :status
    @subject.type.should == :string
    @subject.default.should == "processing"
  end
  
  it "should accept 3 arguments" do
    @subject = MassiveRecord::ORM::Field.new(:status, :boolean, { :column => :st, :default => false })
    @subject.name.should == :status
    @subject.column.should == :st
    @subject.type.should == :boolean
    @subject.default.should be_false
  end
  
  describe "#decode" do
    it "should decode a boolean value" do
      @subject = MassiveRecord::ORM::Field.new(:status, :boolean)
      @subject.decode("1").should be_true
      @subject.decode("0").should be_false
      @subject.decode("").should be_nil
      @subject.decode(nil).should be_nil
    end

    it "should decode a string value" do
      @subject = MassiveRecord::ORM::Field.new(:status, :string)
      @subject.decode("value").should == "value"
      @subject.decode("").should == ""
      @subject.decode(nil).should be_nil
    end

    it "should decode an integer value" do
      @subject = MassiveRecord::ORM::Field.new(:status, :integer)
      @subject.decode("1").should == 1
      @subject.decode("").should be_nil
      @subject.decode(nil).should be_nil
    end

    it "should decode a date type" do
      today = Date.today
      @subject = MassiveRecord::ORM::Field.new(:created_at, :date)
      @subject.decode(today.to_s) == today
      @subject.decode("").should be_nil
      @subject.decode(nil).should be_nil
    end
    
    it "should decode a time type" do
      today = Time.now
      @subject = MassiveRecord::ORM::Field.new(:created_at, :time)
      @subject.decode(today.to_s) == today
      @subject.decode("").should be_nil
      @subject.decode(nil).should be_nil
    end
    
  end
end
