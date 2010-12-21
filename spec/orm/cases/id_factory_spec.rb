require 'spec_helper'
require 'orm/models/person'

describe "id factory" do
  it "should be a singleton" do
    MassiveRecord::ORM::IdFactory.included_modules.should include(Singleton)
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
      include SetUpHbaseConnectionBeforeAll
      include SetTableNamesToTestTable

      before do
        @factory = MassiveRecord::ORM::IdFactory.instance
      end

      it "should increment start a new sequence on 1" do
        @factory.next_for(Person).should == 1
      end

      it "should increment value one by one" do
        5.times do |index|
          expected_id = index + 1
          @factory.next_for(Person).should == expected_id
        end
      end

      it "should maintain ids separate for each table" do
        3.times { @factory.next_for(Person) }
        @factory.next_for("cars").should == 1
      end
    end
  end
end
