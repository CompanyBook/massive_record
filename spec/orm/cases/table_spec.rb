require 'spec_helper'

describe "table" do

  before do
    @subject = MassiveRecord::ORM::Table
  end
  
  describe "column_families" do
    
    before do      
      @subject.column_family(:info) do
        field :first_name
        field :last_name
      end
      
      @subject.column_family(:misc) do
        field :status
      end      
      
      @subject = @subject.new
    end
    
    it "should have a collection of column families" do
      @subject.column_families.should be_a_kind_of(Array)
    end
    
    it "should have an attributes schema" do
      @subject.attributes_schema.keys.sort.should == ["info:first_name", "info:last_name", "misc:status"].sort
    end
    
  end
    
end
