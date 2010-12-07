require 'spec_helper'

describe "column_family" do
  before do
    @subject = MassiveRecord::ORM::ColumnFamily.new(:info) do
      field :first_name
      field :last_name
    end
  end
  
  it "should have a name" do
    @subject.name.should == :info
  end
  
  it "should have a collection a fields" do
    @subject.fields.should be_a_kind_of(MassiveRecord::ORM::Fields)
  end
  
  describe "fields" do
  
    it "should have a two keys made of the column family name and column name" do
      @subject.fields.keys.sort == ["info:first_name", "info:last_name"].to_s
    end
    
    it "should have a Field object" do
      @subject.fields["info:first_name"].should be_a_kind_of(MassiveRecord::ORM::Field)
    end
  
  end
  
end
