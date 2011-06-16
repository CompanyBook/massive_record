require 'spec_helper'
require 'orm/models/person'

describe "id factory" do
  subject { MassiveRecord::ORM::IdFactory.instance }

  it "should be a singleton" do
    MassiveRecord::ORM::IdFactory.included_modules.should include(Singleton)
  end

  describe "#next_for" do
    describe "dry" do
      include MockMassiveRecordConnection

      it "should respond to next_for" do
        subject.should respond_to :next_for
      end

      it "should use incomming table name if it's a string" do
        subject.should_receive(:next_id).with(hash_including(:table => "test_table"))
        subject.next_for "test_table"
      end

      it "should use incomming table name if it's a symbol" do
        subject.should_receive(:next_id).with(hash_including(:table => "test_table"))
        subject.next_for :test_table
      end

      it "should ask object for it's table name if it responds to that" do
        Person.should_receive(:table_name).and_return("people")
        subject.should_receive(:next_id).with(hash_including(:table => "people"))
        subject.next_for(Person)
      end

      it "should have class method next_for and delegate it to it's instance" do
        subject.should_receive(:next_for).with("cars")
        MassiveRecord::ORM::IdFactory.next_for("cars")
      end
    end



    describe "database" do
      include SetUpHbaseConnectionBeforeAll
      include SetTableNamesToTestTable

      after do
        MassiveRecord::ORM::IdFactory.destroy_all
      end

      it "should increment start a new sequence on 1" do
        subject.next_for(Person).should == 1
      end

      it "should increment value one by one" do
        5.times do |index|
          expected_id = index + 1
          subject.next_for(Person).should == expected_id
        end
      end

      it "should maintain ids separate for each table" do
        3.times { subject.next_for(Person) }
        subject.next_for("cars").should == 1
      end


      describe "old string representation of integers" do
        it "increments correctly when value is '1'" do
          old_ensure = MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings
          MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings = true

          subject.next_for(Person)

          # Enter incompatible data, number as string.
          MassiveRecord::ORM::IdFactory.table.first.tap do |row|
            row.update_column(
              MassiveRecord::ORM::IdFactory::COLUMN_FAMILY_FOR_TABLES,
              Person.table_name,
              MassiveRecord::ORM::Base.coder.dump(1)
            )
            row.save
          end

          subject.next_for(Person).should eq 2

          MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings = old_ensure
        end
      end
    end
  end
end
