require 'spec_helper'
require 'orm/models/test_class'

describe MassiveRecord::ORM::Base do
  include MockMassiveRecordConnection

  describe "#object" do
    it "should have a table name" do
      TestClass.table_name == "test_classes"
    end
    
    it "should have a model name" do
      TestClass.model_name == "TestClass"
    end
    
    it "should have a table name with prefix" do
      MassiveRecord::ORM::Table.table_name_prefix = "_production"
      TestClass.table_name == "test_classes_production"
    end
    
    it "should have a table name with suffix" do
      MassiveRecord::ORM::Table.table_name_suffix = "production_"
      TestClass.table_name == "production_test_classes"
    end
  end

  describe "#initialize" do
    it "should take a set of attributes and make them readable" do
      model = TestClass.new :foo => :bar
      model.foo.should == :bar
    end

    it "should initialize an object via init_with()" do
      model = TestClass.allocate
      model.init_with 'attributes' => {:foo => :bar}
      model.foo.should == :bar
    end

    it "should stringify keys set on attributes" do
      model = TestClass.allocate
      model.init_with 'attributes' => {:foo => :bar}
      model.attributes.keys.should include("foo")
    end

    it "should return nil as id by default" do
      TestClass.new.id.should be_nil
    end
  end

  describe "equality" do
    it "should evaluate one object the same as equal" do
      person = Person.find(1)
      person.should == person
    end

    it "should evaluate two objects of same class and id as ==" do
      Person.find(1).should == Person.find(1)
    end

    it "should evaluate two objects of same class and id as eql?" do
      Person.find(1).eql?(Person.find(1)).should be_true
    end

    it "should not be equal if ids are different" do
      Person.find(1).should_not == Person.find(2)
    end

    it "should not be equal if class are different" do
      TestClass.find(1).should_not == Person.find(2)
    end
  end

  describe "#to_param" do
    it "should return nil if no id has been set" do
      TestClass.new.to_param.should be_nil
    end

    it "should return the id if id has been set" do
      TestClass.new(:id => 1).to_param.should == "1"
    end
  end
end
