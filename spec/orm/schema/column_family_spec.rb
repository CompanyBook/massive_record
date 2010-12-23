require 'spec_helper'

describe MassiveRecord::ORM::Schema::ColumnFamily do
  before do
    @column_family = MassiveRecord::ORM::Schema::ColumnFamily.new(:name)
  end

  describe "initializer" do
    it "should take a name" do
      column_family = MassiveRecord::ORM::Schema::ColumnFamily.new "family_name"
      column_family.name.should == "family_name"
    end
  end

  it "should cast name to string" do
    @column_family.name = :name
    @column_family.name.should == "name"
  end

  it "should not allow blank name" do
    lambda { @column_family.name = nil }.should raise_error ArgumentError
  end

  it "should compare two column families based on name" do
    column_family_1 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name)
    column_family_2 = MassiveRecord::ORM::Schema::ColumnFamily.new(:name)

    column_family_1.should == column_family_2
    column_family_1.eql?(column_family_2).should be_true
  end
end
