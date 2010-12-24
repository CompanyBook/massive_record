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
end
