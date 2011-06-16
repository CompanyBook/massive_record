require 'spec_helper'
require 'orm/models/test_class'
require 'orm/models/friend'
require 'orm/models/best_friend'

describe MassiveRecord::ORM::Base do
  include MockMassiveRecordConnection

  describe "table name" do
    before do
      TestClass.reset_table_name_configuration!
      Friend.reset_table_name_configuration!
      BestFriend.reset_table_name_configuration!
    end

    after do
      TestClass.reset_table_name_configuration!
      Friend.reset_table_name_configuration!
      BestFriend.reset_table_name_configuration!
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

    it "first sub class should have the same table name as base class" do
      Friend.table_name.should == Person.table_name
    end

    it "second sub class should have the same table name as base class" do
      BestFriend.table_name.should == Person.table_name
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

      it "should be possible to call set_table_name" do
        TestClass.set_table_name("foo")
        TestClass.table_name.should == "foo"
      end

      it "sub class should have have table name overridden" do
        Friend.table_name = "foo"
        Friend.table_name.should == "foo"
      end
    end
  end

  it "should have a model name" do
    TestClass.model_name.should == "TestClass"
  end

  describe "#initialize" do
    it "should take a set of attributes and make them readable" do
      model = TestClass.new :foo => 'bar'
      model.foo.should == 'bar'
    end

    it "should raise error if attribute is unknown" do
      lambda { TestClass.new :unknown => 'attribute' }.should raise_error MassiveRecord::ORM::UnknownAttributeError
    end

    it "should initialize an object via init_with()" do
      model = TestClass.allocate
      model.init_with 'attributes' => {:foo => 'bar'}
      model.foo.should == 'bar'
    end

    it "should set attributes where nil is not allowed if it is not included in attributes list" do
      model = TestClass.allocate
      model.init_with 'attributes' => {:foo => 'bar'}
      model.hash_not_allow_nil.should == {}
    end

    it "should set attributes where nil is not allowed if it is included, but the value is nil" do
      model = TestClass.allocate
      model.init_with 'attributes' => {:hash_not_allow_nil => nil, :foo => 'bar'}
      model.hash_not_allow_nil.should == {}
    end

    it "should not set override attributes where nil is allowed" do
      model = TestClass.allocate
      model.init_with 'attributes' => {:foo => nil}
      model.foo.should be_nil
    end

    it "should set attributes where nil is not allowed when calling new" do
      TestClass.new.hash_not_allow_nil.should == {}
    end

    it "should stringify keys set on attributes" do
      model = TestClass.allocate
      model.init_with 'attributes' => {:foo => :bar}
      model.attributes.keys.should include("foo")
    end

    it "should return nil as id by default" do
      TestClass.new.id.should be_nil
    end

    it "should be possible to create an object with nil as argument" do
      lambda { TestClass.new(nil) }.should_not raise_error
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

  describe "intersection and union operation" do
    it "should correctly find intersection two sets" do
      ([Person.find(1)] & [Person.find(1), Person.find(2)]).should == [Person.find(1)]
    end

    it "should correctly find union of two sets" do
      ([Person.find(1)] | [Person.find(1), Person.find(2)]).should == [Person.find(1), Person.find(2)]
    end

    it "should correctly find intersection between two sets with different classes" do
      ([Person.find(1)] & [TestClass.find(1)]).should == []
    end

    it "should correctly find union between two sets with different classes" do
      ([Person.find(1)] | [TestClass.find(1)]).should == [Person.find(1), TestClass.find(1)]
    end
  end

  describe "#to_param" do
    it "should return nil if new record" do
      TestClass.new.to_param.should be_nil
    end

    it "should return the id if persisted" do
      TestClass.create!(1).to_param.should == "1"
    end
  end

  describe "#to_key" do
    it "should return nil if new record" do
      TestClass.new.to_key.should be_nil
    end

    it "should return id in an array persisted" do
      TestClass.create!("1").to_key.should == ["1"]
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
      @person.inspect.should include '#<Person id: "3",'
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


  describe "logger" do
    it "should respond to logger" do
      MassiveRecord::ORM::Base.should respond_to :logger
    end

    it "should respond to logger=" do
      MassiveRecord::ORM::Base.should respond_to :logger=
    end
  end

  describe "read only" do
    it "should not be read only by default" do
      TestClass.new.should_not be_readonly
    end

    it "should be read only if asked to" do
      test = TestClass.new
      test.readonly!
      test.should be_readonly
    end
  end


  describe "#base_class" do
    it "should return correct base class for direct descendant of Base" do
      Person.base_class.should == Person
    end

    it "should return Person when asking a descendant of Person" do
      Friend.base_class.should == Person
    end

    it "should return Person when asking a descendant of Person multiple levels" do
      BestFriend.base_class.should == Person
    end
  end
  
  
  describe "#clone" do
    before do
      @test_object = TestClass.create!("1", :foo => 'bar')
      @clone_object = @test_object.clone
    end
    
    it "should be the same object class" do
      @test_object.class.should == @clone_object.class
    end
    
    it "should have a different object_id" do
      @test_object.object_id.should_not == @clone_object.object_id
    end
    
    it "should have the same attributes" do
      @test_object.foo.should == @clone_object.foo
    end
    
    it "should have a nil id" do
      @clone_object.id.should be_nil
    end
  end


  describe "coder" do
    it "should have a default coder" do
      Person.coder.should be_instance_of MassiveRecord::ORM::Coders::JSON
    end
  end

  describe "id as first argument to" do
    [:new, :create, :create!].each do |creation_method|
      describe creation_method do
        it "sets first argument as records id" do
          TestClass.send(creation_method, "idfirstarg").id.should == "idfirstarg"
        end

        it "sets first argument as record id, hash as it's attribute" do
          TestClass.send(creation_method, "idfirstarg", foo: 'works').foo.should == 'works'
        end
      end
    end
  end
end
