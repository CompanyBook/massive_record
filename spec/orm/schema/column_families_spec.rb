require 'spec_helper'

describe MassiveRecord::ORM::Schema::ColumnFamilies do
  before do
    @column_families = MassiveRecord::ORM::Schema::ColumnFamilies.new
  end

  it "should be a kind of set" do
    @column_families.should be_a_kind_of Set
  end

  it "should be possible to add column families" do
    family = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :info)
    @column_families << family
    @column_families.first.should == family
  end

  describe "add column families to the set" do
    it "should not be possible to add two column families with the same name" do
      family_1 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :info)
      family_2 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :info)
      @column_families << family_1
      @column_families.add?(family_2).should be_nil
    end

    it "should add self to column_family when familiy is added" do
      family = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :info)
      @column_families << family
      family.column_families.should == @column_families
    end

    it "should add self to column_family when familiy is added with a question" do
      family = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :info)
      @column_families.add? family
      family.column_families.should == @column_families
    end

    it "should raise error if invalid column familiy is added" do
      invalid_family = MassiveRecord::ORM::Schema::ColumnFamily.new
      lambda { @column_families << invalid_family }.should raise_error MassiveRecord::ORM::Schema::InvalidColumnFamily
    end

    it "should raise an error if a two column families are added with the same field names" do
      family_1 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :misc)
      family_2 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :info)

      family_1 << MassiveRecord::ORM::Schema::Field.new(:name => "Foo")
      @column_families << family_1
      
      family_2 << MassiveRecord::ORM::Schema::Field.new(:name => "Foo")
      lambda { @column_families << family_2 }.should raise_error MassiveRecord::ORM::Schema::InvalidColumnFamily
    end
  end

  describe "#to_hash" do
    before do
      @column_families = MassiveRecord::ORM::Schema::ColumnFamilies.new
      @column_family_info = MassiveRecord::ORM::Schema::ColumnFamily.new :name => :info
      @column_family_misc = MassiveRecord::ORM::Schema::ColumnFamily.new :name => :misc

      @column_families << @column_family_info << @column_family_misc

      @name_field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @phone_field = MassiveRecord::ORM::Schema::Field.new(:name => :phone)
      @column_family_info << @name_field << @phone_field

      @misc_field = MassiveRecord::ORM::Schema::Field.new(:name => :misc)
      @other_field = MassiveRecord::ORM::Schema::Field.new(:name => :other)
      @column_family_misc << @misc_field << @other_field
    end

    it "should return nil if no fields are added" do
      @column_families.clear
      @column_families.to_hash.should == {}
    end

    it "should contain added fields from info" do
      @column_families.to_hash.should include("name" => @name_field)
      @column_families.to_hash.should include("phone" => @phone_field)
    end

    it "should contain added fields from misc" do
      @column_families.to_hash.should include("misc" => @misc_field)
      @column_families.to_hash.should include("other" => @other_field)
    end
  end

  describe "#attribute_names" do
    before do
      @column_families = MassiveRecord::ORM::Schema::ColumnFamilies.new
      @column_family_info = MassiveRecord::ORM::Schema::ColumnFamily.new :name => :info
      @column_family_misc = MassiveRecord::ORM::Schema::ColumnFamily.new :name => :misc

      @column_families << @column_family_info << @column_family_misc

      @name_field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @phone_field = MassiveRecord::ORM::Schema::Field.new(:name => :phone)
      @column_family_info << @name_field << @phone_field

      @misc_field = MassiveRecord::ORM::Schema::Field.new(:name => :misc)
      @other_field = MassiveRecord::ORM::Schema::Field.new(:name => :other)
      @column_family_misc << @misc_field << @other_field
    end

    it "should return nil if no fields are added" do
      @column_families.clear
      @column_families.attribute_names.should == []
    end

    it "should contain added fields from info" do
      @column_families.attribute_names.should include("name", "phone")
    end

    it "should contain added fields from misc" do
      @column_families.attribute_names.should include("misc", "other")
    end
  end

  describe "#attribute_name_taken?" do
    before do
      @column_families = MassiveRecord::ORM::Schema::ColumnFamilies.new
      @column_family_info = MassiveRecord::ORM::Schema::ColumnFamily.new :name => :info
      @column_family_misc = MassiveRecord::ORM::Schema::ColumnFamily.new :name => :misc

      @column_families << @column_family_info << @column_family_misc

      @name_field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @phone_field = MassiveRecord::ORM::Schema::Field.new(:name => :phone)
      @column_family_info << @name_field << @phone_field

      @misc_field = MassiveRecord::ORM::Schema::Field.new(:name => :misc)
      @other_field = MassiveRecord::ORM::Schema::Field.new(:name => :other)
      @column_family_misc << @misc_field << @other_field
    end

    it "should return true if name is taken" do
      @column_families.attribute_name_taken?("phone").should be_true
    end

    it "should accept and return true if name, given as a symbol, is taken" do
      @column_families.attribute_name_taken?(:other).should be_true
    end

    it "should return false if name is not taken" do
      @column_families.attribute_name_taken?("not_taken").should be_false
    end

    it "should return the same answer if asked from a field" do
      @name_field.fields.attribute_name_taken?("misc").should be_true
    end

    it "should return false if only asked to check inside of it's own set" do
      @name_field.fields.attribute_name_taken?("misc", true).should be_false
    end
  end

  describe "#family_by_name and or_new" do
    before do
      @family_info = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :info)
      @family_misc = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :misc)
      @column_families << @family_info << @family_misc
    end

    it "should return nil if name is not found" do
      @column_families.family_by_name("foo").should be_nil
    end

    it "should return family object for given name" do
      @column_families.family_by_name("info").should == @family_info
    end

    it "should return family object for given name as symbol" do
      @column_families.family_by_name(:info).should == @family_info
    end

    it "should create and add new family on to self" do
      family = @column_families.family_by_name_or_new("foo")
      family.should be_instance_of MassiveRecord::ORM::Schema::ColumnFamily
      @column_families.should include(family)
    end

    it "should simply return known method when asked for family_or_new when name exists" do
      @column_families.family_by_name_or_new("info").should == @family_info
    end
  end
end
