require 'spec_helper'

class TestColumnInterface
  include MassiveRecord::ORM::Schema::ColumnInterface
end

describe MassiveRecord::ORM::Schema::TableInterface do
  after do
    TestColumnInterface.fields = nil
  end

  it "should respond_to default_attributes_from_schema" do
    TestColumnInterface.should respond_to :default_attributes_from_schema
  end

  it "should have fields set to nil if no fields are defined" do
    TestColumnInterface.fields.should be_nil
  end

  it "should have one field if one field is added" do
    class TestColumnInterface
      field :field_name, :string
    end

    TestColumnInterface.should have(1).fields
    TestColumnInterface.fields.first.name.should == "field_name"
  end

  it "should not be possible to have to fields with the same name" do
    lambda {
      class TestColumnInterface
        field :will_raise_error
        field :will_raise_error
      end
    }.should raise_error MassiveRecord::ORM::Schema::InvalidField
  end

  it "should return attributes schema based on DSL" do
    class TestColumnInterface
      field :name
      field :age, :integer, :default => 1
    end

    TestColumnInterface.attributes_schema["name"].type.should == :string
    TestColumnInterface.attributes_schema["age"].type.should == :integer
    TestColumnInterface.attributes_schema["age"].default.should == 1
  end

  it "should make attributes_schema readable from instances" do
    class TestColumnInterface
      field :name
    end

    TestColumnInterface.new.attributes_schema["name"].type.should == :string
  end

  it "should have a list of known attribute names" do
    class TestColumnInterface
      field :name, :string
      field :age, :integer
    end

    TestColumnInterface.should have(2).known_attribute_names
    TestColumnInterface.known_attribute_names.should include("name", "age")
  end

  it "should give us default attributes from schema" do
    class TestColumnInterface
      field :name
      field :age, :integer, :default => 1
    end

    defaults = TestColumnInterface.default_attributes_from_schema
    defaults["name"].should be_nil
    defaults["age"].should == 1
  end
end
