require 'spec_helper'

class TestInterface
  include MassiveRecord::ORM::Schema::TableInterface
end

class TestInterfaceSubClass < TestInterface
end

describe MassiveRecord::ORM::Schema::TableInterface do
  after do
    TestInterface.column_families = nil
    TestInterfaceSubClass.column_families = nil
  end


  it "should respond_to column_family" do
    TestInterface.should respond_to :column_family
  end

  it "should respond_to column_families" do
    TestInterface.should respond_to :column_families
  end

  it "should be possible to add column familiy through DSL" do
    class TestInterface
      column_family :misc do; end
    end

    TestInterface.column_families.collect(&:name).should include("misc")
  end

  it "should be possible to add fields to a column families" do
    class TestInterface
      column_family :info do
        field :name
      end
    end

    TestInterface.known_attribute_names.should == ["name"]
  end

  it "should return attributes schema based on DSL" do
    class TestInterface
      column_family :info do
        field :name
        field :age, :integer, :default => 1
      end
    end

    TestInterface.attributes_schema["name"].type.should == :string
    TestInterface.attributes_schema["age"].type.should == :integer
    TestInterface.attributes_schema["age"].default.should == 1
  end

  it "should raise an error if you try to add same field name twice" do
    lambda { 
      class TestInterface
        column_family :info do
          field :name
          field :name
        end
      end
    }.should raise_error MassiveRecord::ORM::Schema::InvalidField
  end

  it "should give us default attributes from schema" do
    class TestInterface
      column_family :info do
        field :name
        field :age, :integer, :default => 1
      end
    end

    defaults = TestInterface.default_attributes_from_schema
    defaults["name"].should be_nil
    defaults["age"].should == 1
  end

  it "should make attributes_schema readable from instances" do
    class TestInterface
      column_family :info do
        field :name
      end
    end

    TestInterface.new.attributes_schema["name"].type.should == :string
  end

  it "should make a column familiy auto load it's fields" do
    class TestInterface
      column_family :info do
        autoload_fields
      end
    end

    TestInterface.autoloaded_column_family_names.should == ["info"]
  end

  it "should not be shared amonb subclasses" do
    class TestInterface
      column_family :info do
        autoload_fields
      end
    end

    TestInterface.column_families.should_not be_nil
    TestInterfaceSubClass.column_families.should be_nil
  end


  describe "dynamically adding a field" do
    it "should be possible to dynamically add a field" do
      TestInterface.add_field_to_column_family :info, :name, :default => "NA"

      TestInterface.should have(1).column_families

      family = TestInterface.column_families.first
      family.name.should == "info"

      family.fields.first.name.should == "name"
      family.fields.first.default.should == "NA"
    end

    it "should be possible to set field's type just like the DSL" do
      TestInterface.add_field_to_column_family :info, :age, :integer, :default => 0

      TestInterface.column_families.first.fields.first.name.should == "age"
      TestInterface.column_families.first.fields.first.type.should == :integer
      TestInterface.column_families.first.fields.first.default.should == 0
    end

    it "should call class' undefine_attribute_methods to make sure it regenerates for newly added" do
      TestInterface.should_receive(:undefine_attribute_methods)
      TestInterface.add_field_to_column_family :info, :name, :default => "NA"
    end
  end
end
