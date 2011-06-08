require 'spec_helper'
require 'orm/models/test_class'
require 'orm/models/person'

describe "finders" do
  describe "#find dry test" do
    include MockMassiveRecordConnection

    before do
      @mocked_table = mock(MassiveRecord::Wrapper::Table, :to_ary => []).as_null_object
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

    it "should raise an error if conditions are given to first" do
      lambda { Person.first(:conditions => "foo = 'bar'") }.should raise_error ArgumentError
    end

    it "should raise an error if conditions are given to all" do
      lambda { Person.all(:conditions => "foo = 'bar'") }.should raise_error ArgumentError
    end

    it "should raise an error if conditions are given to find" do
      lambda { Person.find(:conditions => "foo = 'bar'") }.should raise_error ArgumentError
    end

    it "should ask the table to look up by it's id" do
      @mocked_table.should_receive(:find).with("ID1", anything).and_return(@row)
      Person.find("ID1")
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
      Person.first.should be_nil
    end

    it "should raise an error if not exactly the id is found" do
      @mocked_table.should_receive(:find).and_return(@row)
      lambda { Person.find("ID") }.should raise_error(MassiveRecord::ORM::RecordNotFound)
    end

    it "should raise error if not all ids are found" do
      @mocked_table.should_receive(:find).and_return([@row, @row_2])
      lambda { Person.find("ID", "ID2") }.should raise_error(MassiveRecord::ORM::RecordNotFound)
    end
  end

  describe "all" do
    it "should respond to all" do
      TestClass.should respond_to :all
    end

    it "should call find with :all" do
      TestClass.should_receive(:do_find).with(:all, anything)
      TestClass.all
    end

    it "should delegate all's call to find with it's args as second argument" do
      options = {:foo => :bar}
      TestClass.should_receive(:do_find).with(anything, options)
      TestClass.all options
    end
  end

  describe "first" do
    it "should respond to first" do
      TestClass.should respond_to :first
    end

    it "should call find with :first" do
      TestClass.should_receive(:do_find).with(:all, {:limit => 1}).and_return([])
      TestClass.first
    end

    it "should delegate first's call to find with it's args as second argument" do
      options = {:foo => :bar}
      TestClass.should_receive(:do_find).with(anything, hash_including(options)).and_return([])
      TestClass.first options
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

    it "should raise record not found error" do
      lambda { Person.find("not_found") }.should raise_error MassiveRecord::ORM::RecordNotFound
    end

    it "should raise MassiveRecord::ORM::RecordNotFound error if table does not exist" do
      Person.table.destroy
      expect { Person.find("id") }.to raise_error MassiveRecord::ORM::RecordNotFound
    end

    it "should return the person object when found" do
      @person.name.should == "John Doe"
      @person.email.should == "john@base.com"
      @person.age.should == 20
    end

    it "should find first person" do
      Person.first.should == @person
    end

    it "should find all" do
      all = Person.all
      all.should include @person, @bob
      all.length.should == 2
    end

    it "should find all persons, even if it is more than 10" do
      15.times { |i| Person.create! "id-#{i}", :name => "Going to die :-(", :age => i + 20 }
      Person.all.length.should > 10
    end

    it "should raise error if not all requested records was found" do
      lambda { Person.find(["ID1", "not exists"]) }.should raise_error MassiveRecord::ORM::RecordNotFound
    end

    it "should return what it finds if asked to" do
      lambda { Person.find(["ID1", "not exists"], :skip_expected_result_check => true) }.should_not raise_error MassiveRecord::ORM::RecordNotFound
    end
  end
  
  describe "#find_in_batches" do
    include CreatePeopleBeforeEach
        
    it "should iterate through a collection of group of rows using a batch process" do
      group_number = 0
      batch_size = 3
      Person.find_in_batches(:batch_size => batch_size) do |rows|
        group_number += 1
        rows.each do |row|
          row.id.should_not be_nil
        end
      end        
      group_number.should == @table_size / 3
    end

    it "should not do a thing if table does not exist" do
      Person.table.destroy

      counter = 0

      Person.find_in_batches(:batch_size => 3) do |rows|
        rows.each do |row|
          counter += 1
        end
      end

      counter.should == 0
    end
    
    it "should iterate through a collection of rows using a batch process" do
      rows_number = 0
      Person.find_each(:batch_size => 3) do |row|
        row.id.should_not be_nil
        rows_number += 1
      end
      rows_number.should == @table_size
    end
  end

  describe "#exists?" do
    include CreatePersonBeforeEach

    it "should return true if a row exists with given id" do
      Person.exists?("ID1").should be_true
    end

    it "should return false if a row does not exists with given id" do
      Person.exists?("unkown").should be_false
    end
  end
end
