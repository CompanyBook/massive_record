require 'spec_helper'

describe MassiveRecord::ORM::Schema::Field do
  describe "initializer" do
    %w(name column_family column type default).each do |attr_name|
      it "should set #{attr_name}" do
        field = MassiveRecord::ORM::Schema::Field.new attr_name => "a_value"
        field.send(attr_name).should == "a_value"
      end
    end
  end

  it "should cast name to string" do
    field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
    field.name.should == "name"
  end

  it "should compare two column families based on name" do
    field_1 = MassiveRecord::ORM::Schema::Field.new(:name => :name)
    field_2 = MassiveRecord::ORM::Schema::Field.new(:name => :name)

    field_1.should == field_2
    field_1.eql?(field_2).should be_true
  end

  it "should have the same hash value for two families with the same name" do
    field_1 = MassiveRecord::ORM::Schema::Field.new(:name => :name)
    field_2 = MassiveRecord::ORM::Schema::Field.new(:name => :name)

    field_1.hash.should == field_2.hash
  end
end
