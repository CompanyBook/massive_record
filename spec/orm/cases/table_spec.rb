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
      autoload_fields
    end
  end

  after do
    @subject.column_families = nil
  end
  
  describe "column_families" do
    it "should have a collection of column families" do
      @subject.column_families.should be_a_kind_of(Set)
    end
    
    it "should have an attributes schema" do
      @subject.attributes_schema.should include("first_name", "last_name", "status")
    end
  end
end
