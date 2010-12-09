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
    end

    it "should have at least one argument" do
      lambda { Person.find }.should raise_error ArgumentError
      
    end

    it "should raise RecordNotFound if id is nil" do
      lambda { Person.find(nil) }.should raise_error MassiveRecord::ORM::RecordNotFound
    end

    it "should ask the table to look up by it's id" do
      @mocked_table.should_receive(:find).with(1).and_return(@row)
      Person.find(1)
    end

    %w(first last all).each do |method|
      it "should call table's #{method} on find(:{method})" do
        @mocked_table.should_receive(method).and_return(@row)
        Person.find(method.to_sym)
      end
    end
  end

  %w(first last all).each do |method|
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

    it "should find last person" do
      Person.last.should == @bob
    end

    it "should find all" do
      all = Person.all
      all.should include @person, @bob
      all.length.should == 2
    end
  end
end
