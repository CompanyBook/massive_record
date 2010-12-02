require 'spec_helper'

class TestClass < MassiveRecord::ORM::Base
end

describe MassiveRecord::ORM::Base do
  describe "#object" do
    it "should have a table name" do
      TestClass.table_name == "test_classes"
    end
    
    it "should have a model name" do
      TestClass.model_name == "TestClass"
    end
  end
  describe "#initialize" do
    it "should take a set of attributes and assign them as instance variables" do
      model = TestClass.new :foo => :bar
      model.instance_variable_get("@foo").should == :bar
    end

    it "should initialize an object via init_with()" do
      model = TestClass.allocate
      model.init_with 'attributes' => {:foo => :bar}
      model.instance_variable_get("@foo").should == :bar
    end
  end
end
