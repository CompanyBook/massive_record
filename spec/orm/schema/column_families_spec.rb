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
end
