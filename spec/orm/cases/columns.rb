require 'spec_helper'
require 'orm/models/person'

describe "Person" do
  
  it "should have a list of column families" do
    Person.column_families.should eql([:info])
  end
  
end