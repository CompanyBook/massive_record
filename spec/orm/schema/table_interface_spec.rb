require 'spec_helper'

class TestInterface
  include MassiveRecord::ORM::Schema::TableInterface
end

describe MassiveRecord::ORM::Schema::TableInterface do
  after do
    TestInterface.column_families = nil
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
end
