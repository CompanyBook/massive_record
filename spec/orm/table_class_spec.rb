require 'spec_helper'

describe MassiveRecord::ORM::Table do

  describe "and a Person class" do
    
    it "should list column families" do
      Person.column_families.should eql([:info])
    end  
    
  end
  
end