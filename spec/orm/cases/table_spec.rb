require 'spec_helper'

describe "table" do

  before do
    @subject = MassiveRecord::ORM::Table
    
    @subject.column_family(:info) do
      field :first_name
      field :last_name
    end
    
    @subject.column_family(:misc) do
      field :status, :boolean, :default => false
    end
    
    @subject.column_family(:sandbox) do
      autoload
    end
  end
  
  describe "column_families" do
        
    it "should have a collection of column families" do
      @subject.column_families.should be_a_kind_of(Array)
    end
    
    it "should have one autoloaded column family" do
      p @subject.autoloaded_column_family_names
      @subject.autoloaded_column_family_names.should be_a_kind_of(Array)
      @subject.autoloaded_column_family_names.size.should == 1
      @subject.autoloaded_column_family_names.first.should == :sandbox
    end
    
    it "should have an attributes schema" do
      @subject.attributes_schema.should include("first_name", "last_name", "status")
    end
    
  end
    
end
