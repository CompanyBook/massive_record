require 'spec_helper'
require 'orm/models/person'

describe "Person" do
  
  before do
    @person = Person.new
  end
  
  it "should parse a list of columns" do
    
  end
  
  it "should have a list of column families" do
    Person.column_families.should eql([:info])
  end
  
  it "should have a list of attributes created from the column family 'info'" do
    @person.attributes.keys.sort = ["first_name", "last_name", "email", "points", "date_of_birth", "status"].sort
  end
  
  it "should default an attribute to its default value" do
    @person.points.should == 1
  end
  
  it "should parse a Date field properly" do
    @person.date_of_birth.should be_kind_of_a(Date)
  end
  
  it "should parse a Boolean field properly" do
    @person.status.should be_false
  end
  
end