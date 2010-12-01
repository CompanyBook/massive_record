require 'spec_helper'

describe MassiveRecord::ORM::Table do

  describe "and a Person class" do
    
    it "should have a table name" do
      Person.table_name == "people"
    end
    
    it "should have a model name" do
      Person.model_name == "Person"
    end
    
    it "should list column families" do
      Person.column_families.should eql([:info])
    end    
    
  end
  
end