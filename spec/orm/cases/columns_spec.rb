require 'spec_helper'
require 'orm/models/person'
require 'orm/models/test_class'

describe "Person" do
  
  before do
    @person = Person.new
    @person.points = "25"
    @person.date_of_birth = "19850730"
    @person.status = "0"
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
    @person.points.should == 25
  end
  
  it "should parse a Date field properly" do
    @person.date_of_birth.should be_a_kind_of(Date)
  end
  
  it "should parse a Boolean field properly" do
    @person.status.should be_false
  end
  
end
