require 'spec_helper'
require 'orm/models/test_class'
require 'orm/models/person'

describe "finders" do
  describe "#find dry test" do
    include MockMassiveRecordConnection

    before do
      @mocked_table = mock(MassiveRecord::Wrapper::Table).as_null_object
      Person.stub(:table).and_return(@mocked_table)
      
      @row = MassiveRecord::Wrapper::Row.new
      @row.id = "ID1"
      @row.values = { :info => { :name => "John Doe", :age => "29" } }

      @row_2 = MassiveRecord::Wrapper::Row.new
      @row_2.id = "ID2"
      @row_2.values = { :info => { :name => "Bob", :age => "18" } }
    end

    it "should have at least one argument" do
      lambda { Person.find }.should raise_error ArgumentError
      
    end

    it "should raise RecordNotFound if id is nil" do
      lambda { Person.find(nil) }.should raise_error MassiveRecord::ORM::RecordNotFound
    end

    it "should ask the table to look up by it's id" do
      @mocked_table.should_receive(:find).with(1, anything).and_return(@row)
      Person.find(1)
    end
    
    it "should ask the table to fetch rows from a list of ids given as array" do
      @mocked_table.should_receive(:find).with(["ID1", "ID2"], anything).and_return([@row, @row_2])
      people = Person.find(["ID1", "ID2"])
      people.should be_instance_of Array
      people.first.should be_instance_of Person
      people.first.id.should == "ID1"
      people.last.id.should == "ID2"
    end
    
    it "should ask table to fetch rows from a list of ids given as arguments" do
      @mocked_table.should_receive(:find).with(["ID1", "ID2"], anything).and_return([@row, @row_2])
      people = Person.find("ID1", "ID2")
      people.should be_instance_of Array
      people.first.should be_instance_of Person
      people.first.id.should == "ID1"
      people.last.id.should == "ID2"
    end

    it "should raise error if not all multiple ids are found" do
      @mocked_table.should_receive(:find).with(["ID1", "ID2"], anything).and_return([@row])
      lambda { Person.find("ID1", "ID2") }.should raise_error MassiveRecord::ORM::RecordNotFound
    end
    
    it "should call table's first on find(:first)" do
      @mocked_table.should_receive(:first).and_return(@row)
      Person.find(:first)
    end

    it "should call table's all on find(:all)" do
      @mocked_table.should_receive(:all).and_return([@row])
      Person.find(:all)
    end

    it "should return empty array on all if no results was found" do
      @mocked_table.should_receive(:all).and_return([])
      Person.all.should == []
    end

    it "should return nil on first if no results was found" do
      @mocked_table.should_receive(:first).and_return(nil)
      Person.first.should be_nil
    end
  end

  %w(first all).each do |method|
    it "should respond to #{method}" do
      TestClass.should respond_to method
    end

    it "should delegate #{method} to find with first argument as :#{method}" do
      TestClass.should_receive(:find).with(method.to_sym)
      TestClass.send(method)
    end

    it "should delegate #{method}'s call to find with it's args as second argument" do
      options = {:foo => :bar}
      TestClass.should_receive(:find).with(anything, options)
      TestClass.send(method, options)
    end
  end




  describe "#find database test" do
    include CreatePersonBeforeEach

    before do
      @person = Person.find("ID1")

      @row = MassiveRecord::Wrapper::Row.new
      @row.id = "ID2"
      @row.values = {:info => {:name => "Bob", :email => "bob@base.com", :age => "26"}}
      @row.table = @table
      @row.save

      @bob = Person.find("ID2")
    end

    it "should return nil if id is not found" do
      lambda { Person.find("not_found") }.should raise_error MassiveRecord::ORM::RecordNotFound
    end

    it "should return the person object when found" do
      @person.name.should == "John Doe"
      @person.email.should == "john@base.com"
      @person.age.should == "20"
    end

    it "should find first person" do
      Person.first.should == @person
    end

    it "should find all" do
      all = Person.all
      all.should include @person, @bob
      all.length.should == 2
    end
  end
end
