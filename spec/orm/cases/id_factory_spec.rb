require 'spec_helper'
require 'orm/models/person'

describe "id factory" do
  it "should be a singleton" do
    MassiveRecord::ORM::IdFactory.included_modules.should include(Singleton)
  end

  it "should return an instance of self" do
    MassiveRecord::ORM::IdFactory.instance.should be_instance_of MassiveRecord::ORM::IdFactory
  end

  describe "#next_for" do
    describe "dry" do
      include MockMassiveRecordConnection

      before do
        @factory = MassiveRecord::ORM::IdFactory.instance
      end

      it "should respond to next_for" do
        @factory.should respond_to :next_for
      end

      it "should use incomming table name if it's a string" do
        @factory.should_receive(:next_id).with(hash_including(:table => "test_table"))
        @factory.next_for "test_table"
      end

      it "should use incomming table name if it's a symbol" do
        @factory.should_receive(:next_id).with(hash_including(:table => "test_table"))
        @factory.next_for :test_table
      end

      it "should ask object for it's table name if it responds to that" do
        Person.should_receive(:table_name).and_return("people")
        @factory.should_receive(:next_id).with(hash_including(:table => "people"))
        @factory.next_for(Person)
      end
    end



    describe "database" do
      

      before do
        @factory = MassiveRecord::ORM::IdFactory.instance
      end
    end
  end
end
