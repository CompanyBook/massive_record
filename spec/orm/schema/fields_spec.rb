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

  describe "#to_hash" do
    before do
      @name_field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @phone_field = MassiveRecord::ORM::Schema::Field.new(:name => :phone)
      @fields << @name_field << @phone_field
    end

    it "should return nil if no fields are added" do
      @fields.clear
      @fields.to_hash.should == {}
    end

    it "should contain added fields" do
      @fields.to_hash.should include("name" => @name_field)
      @fields.to_hash.should include("phone" => @phone_field)
    end
  end

  describe "#attribute_names" do
    before do
      @name_field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @phone_field = MassiveRecord::ORM::Schema::Field.new(:name => :phone)
      @fields << @name_field << @phone_field
    end

    it "should return nil if no fields are added" do
      @fields.clear
      @fields.attribute_names.should == []
    end

    it "should contain added fields" do
      @fields.attribute_names.should include("name", "phone")
    end
  end

  describe "#attribute_name_taken?" do
    before do
      @name_field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @phone_field = MassiveRecord::ORM::Schema::Field.new(:name => :phone)
      @fields << @name_field << @phone_field
    end

    describe "with no contained_in" do
      it "should return true if name is taken" do
        @fields.attribute_name_taken?("phone").should be_true
      end

      it "should accept and return true if name, given as a symbol, is taken" do
        @fields.attribute_name_taken?(:phone).should be_true
      end

      it "should return false if name is not taken" do
        @fields.attribute_name_taken?("not_taken").should be_false
      end
    end

    describe "with contained_in set" do
      before do
        @fields.contained_in = MassiveRecord::ORM::Schema::ColumnFamily.new :name => "Family"
      end

      it "should ask object it is contained in for the truth about if attribute name is taken" do
        @fields.contained_in.should_receive(:attribute_name_taken?).and_return true
        @fields.attribute_name_taken?(:foo).should be_true
      end

      it "should not ask object it is contained in if asked not to" do
        @fields.contained_in.should_not_receive(:attribute_name_taken?)
        @fields.attribute_name_taken?(:foo, true).should be_false
      end
    end
  end

  describe "#field_by_name" do
    before do
      @name_field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @phone_field = MassiveRecord::ORM::Schema::Field.new(:name => :phone)
      @fields << @name_field << @phone_field
    end

    it "should return nil if nothing is found" do
      @fields.field_by_name("unkown").should be_nil
    end

    it "should return found field" do
      @fields.field_by_name("name").should == @name_field
    end

    it "should return found field given as symbol" do
      @fields.field_by_name(:name).should == @name_field
    end
  end
end
