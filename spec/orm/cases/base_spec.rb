require 'spec_helper'
require 'orm/models/test_class'

describe MassiveRecord::ORM::Base do
  include MockMassiveRecordConnection

  describe "table name" do
    before do
      TestClass.reset_table_name_configuration!
    end

    it "should have a table name" do
      TestClass.table_name.should == "test_classes"
    end
    
    it "should have a table name with prefix" do
      TestClass.table_name_prefix = "prefix_"
      TestClass.table_name.should == "prefix_test_classes"
    end
    
    it "should have a table name with suffix" do
      TestClass.table_name_suffix = "_suffix"
      TestClass.table_name.should == "test_classes_suffix"
    end
    
    describe "set explicitly" do
      it "should be able to set it" do
        TestClass.table_name = "foo"
        TestClass.table_name.should == "foo"
      end

      it "should have a table name with prefix" do
        TestClass.table_name = "foo"
        TestClass.table_name_prefix = "prefix_"
        TestClass.table_name.should == "prefix_foo"
      end
      
      it "should have a table name with suffix" do
        TestClass.table_name = "foo"
        TestClass.table_name_suffix = "_suffix"
        TestClass.table_name.should == "foo_suffix"
      end
    end
  end

  it "should have a model name" do
    TestClass.model_name.should == "TestClass"
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
    it "should return nil if new record" do
      TestClass.new.to_param.should be_nil
    end

    it "should return the id if persisted" do
      TestClass.create!(:id => 1).to_param.should == "1"
    end
  end

  describe "#to_key" do
    it "should return nil if new record" do
      TestClass.new.to_key.should be_nil
    end

    it "should return id in an array persisted" do
      TestClass.create!(:id => "1").to_key.should == ["1"]
    end
  end

  it "should be able to freeze objects" do
    test_object = TestClass.new
    test_object.freeze
    test_object.should be_frozen
  end


  describe "#inspect" do
    before do
      @person = Person.new({
        :name => "Bob",
        :age => 3,
        :date_of_birth => Date.today
      })
    end

    it "should wrap inspection string inside of #< >" do
      @person.inspect.should match(/^#<.*?>$/);
    end

    it "should contain it's class name" do
      @person.inspect.should include("Person")
    end

    it "should start with the record's id if it has any" do
      @person.id = 3
      @person.inspect.should include "#<Person id: 3,"
    end

    it "should start with the record's id if it has any" do
      @person.id = nil
      @person.inspect.should include "#<Person id: nil,"
    end

    it "should contain a nice list of it's attributes" do
      i = @person.inspect
      i.should include(%q{name: "Bob"})
      i.should include(%q{age: 3})
    end
  end

  describe "attribute read / write alias" do
    before do
      @test_object = TestClass.new :foo => 'bar'
    end

    it "should read attributes by object[attr]" do
      @test_object[:foo].should == 'bar'
    end

    it "should write attributes by object[attr] = new_value" do
      @test_object["foo"] = "new_value"
      @test_object.foo.should == "new_value"
    end
  end
end
