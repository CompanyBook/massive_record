require 'spec_helper'
require 'orm/models/person'
require 'orm/models/test_class'

describe "Person" do
  
  before do
    @person = Person.new
  end
  
  it "should have a list of column families" do
    Person.column_families.collect(&:name).should include(:info)
  end

  it "should keep different column families per sub class" do
    Person.column_families.collect(&:name).should == [:info]
    TestClass.column_families.collect(&:name).should == [:test_family] 
  end
  
  it "should have a list of attributes created from the column family 'info'" do
    @person.attributes.keys.should include("name", "email", "points", "date_of_birth", "status")
  end
  
  it "should default an attribute to its default value" do
    @person.points.should == 1
  end
  
  it "should parse a Date field properly" do
    pending "Casting not implemented, yet"
    @person.date_of_birth.should be_kind_of_a(Date)
  end
  
  it "should parse a Boolean field properly" do
    pending "Casting not implemented, yet"
    @person.status.should be_false
  end
  
end
