require 'spec_helper'

describe MassiveRecord::ORM::Schema::Fields do
  before do
    @fields = MassiveRecord::ORM::Schema::Fields.new
  end

  it "should be a kind of set" do
    @fields.should be_a_kind_of Set
  end

  describe "add fields to the set" do
    it "should be possible to add fields" do
      @fields << MassiveRecord::ORM::Schema::Field.new(:name => "field")
    end

    it "should add self to field's fields attribute" do
      field = MassiveRecord::ORM::Schema::Field.new(:name => :field)
      @fields << field
      field.fields.should == @fields
    end

    it "should not be possible to add two fields with the same name" do
      @fields << MassiveRecord::ORM::Schema::Field.new(:name => "attr")
      @fields.add?(MassiveRecord::ORM::Schema::Field.new(:name => "attr")).should be_nil
    end

    it "should raise error if invalid column familiy is added" do
      invalid_field = MassiveRecord::ORM::Schema::Field.new
      lambda { @fields << invalid_field }.should raise_error MassiveRecord::ORM::Schema::InvalidField
    end
  end
end
