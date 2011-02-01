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

  it "should make known_attribute_names readable for instances" do
    class TestColumnInterface
      field :name, :string
    end

    TestColumnInterface.new.known_attribute_names.should include('name')
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

  describe "timestamps" do
    before do
      class TestColumnInterface
        timestamps
      end
    end

    it "should have a created_at time field" do
      TestColumnInterface.attributes_schema['created_at'].type.should == :time
    end
  end


  describe "dynamically adding a field" do
    it "should be possible to dynamically add a field" do
      TestColumnInterface.add_field :name, :default => "NA"

      TestColumnInterface.should have(1).fields

      field = TestColumnInterface.fields.first

      field.name.should == "name"
      field.default.should == "NA"
    end

    it "should be possible to set field's type just like the DSL" do
      TestColumnInterface.add_field :age, :integer, :default => 0

      TestColumnInterface.fields.first.name.should == "age"
      TestColumnInterface.fields.first.type.should == :integer
      TestColumnInterface.fields.first.default.should == 0
    end

    it "should call class' undefine_attribute_methods to make sure it regenerates for newly added" do
      TestColumnInterface.should_receive(:undefine_attribute_methods)
      TestColumnInterface.add_field :name, :default => "NA"
    end

    it "should return the new field" do
      field = TestColumnInterface.add_field :age, :integer, :default => 0
      field.should == TestColumnInterface.fields.first
    end

    it "should insert the new field's default value right away" do
      test_interface = TestColumnInterface.new
      test_interface.should_receive("age=").with(1)
      test_interface.add_field :age, :integer, :default => 1
    end
  end
end
