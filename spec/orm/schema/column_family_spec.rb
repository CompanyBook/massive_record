require 'spec_helper'

describe MassiveRecord::ORM::Schema::ColumnFamily do
  describe "initializer" do
    it "should take a name" do
      column_family = MassiveRecord::ORM::Schema::ColumnFamily.new :name => "family_name"
      column_family.name.should == "family_name"
    end

    it "should take the column families it belongs to" do
      families = MassiveRecord::ORM::Schema::ColumnFamilies.new
      column_family = MassiveRecord::ORM::Schema::ColumnFamily.new :name => "family_name"
      column_family.column_families = families
      column_family.column_families.should == families
    end

    it "should set fields contained_in" do
      column_family = MassiveRecord::ORM::Schema::ColumnFamily.new :name => "family_name"
      column_family.fields.contained_in.should == column_family
    end

    it "should set autoload_fields to true" do
      column_family = MassiveRecord::ORM::Schema::ColumnFamily.new :name => "family_name", :autoload_fields => true
      column_family.should be_autoload_fields
    end
  end

  describe "validations" do
    before do
      @families = MassiveRecord::ORM::Schema::ColumnFamilies.new
      @column_family = MassiveRecord::ORM::Schema::ColumnFamily.new :name => "family_name", :column_families => @families
    end

    it "should be valid from before hook" do
      @column_family.should be_valid
    end

    it "should not be valid with a blank name" do
      @column_family.send(:name=, nil)
      @column_family.should_not be_valid
    end

    it "should not be valid without column_families" do
      @column_family.column_families = nil
      @column_family.should_not be_valid
    end

    it "should not be valid if one of it's field is not valid" do
      @field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @column_family << @field
      @field.should_receive(:valid?).and_return(false)
      @column_family.should_not be_valid
    end
  end


  it "should cast name to string" do
    column_family = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :name)
    column_family.name.should == "name"
  end

  it "should compare two column families based on name" do
    column_family_1 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :name)
    column_family_2 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :name)

    column_family_1.should == column_family_2
    column_family_1.eql?(column_family_2).should be_true
  end

  it "should have the same hash value for two families with the same name" do
    column_family_1 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :name)
    column_family_2 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name => :name)

    column_family_1.hash.should == column_family_2.hash
  end



  describe "delegation to fields" do
    before do
      @families = MassiveRecord::ORM::Schema::ColumnFamilies.new
      @column_family = MassiveRecord::ORM::Schema::ColumnFamily.new :name => "family_name", :column_families => @families
    end

    %w(add add? << to_hash attribute_names field_by_name).each do |method_to_delegate_to_fields|
      it "should delegate #{method_to_delegate_to_fields} to fields" do
        @column_family.fields.should_receive(method_to_delegate_to_fields)
        @column_family.send(method_to_delegate_to_fields)
      end
    end
  end

  describe "#attribute_name_taken?" do
    before do
      @column_family = MassiveRecord::ORM::Schema::ColumnFamily.new :name => "family_name", :column_families => @families
      @name_field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
      @phone_field = MassiveRecord::ORM::Schema::Field.new(:name => :phone)
      @column_family << @name_field << @phone_field
    end

    describe "with no contained_in" do
      it "should return true if name is taken" do
        @column_family.attribute_name_taken?("phone").should be_true
      end

      it "should accept and return true if name, given as a symbol, is taken" do
        @column_family.attribute_name_taken?(:phone).should be_true
      end

      it "should return false if name is not taken" do
        @column_family.attribute_name_taken?("not_taken").should be_false
      end
    end

    describe "with contained_in set" do
      before do
        @column_family.contained_in = MassiveRecord::ORM::Schema::ColumnFamilies
      end

      it "should ask object it is contained in for the truth about if attribute name is taken" do
        @column_family.contained_in.should_receive(:attribute_name_taken?).and_return true
        @column_family.attribute_name_taken?(:foo).should be_true
      end

      it "should not ask object it is contained in if asked not to" do
        @column_family.contained_in.should_not_receive(:attribute_name_taken?)
        @column_family.attribute_name_taken?(:foo, true).should be_false
      end
    end
  end
end
