require 'spec_helper'
require 'orm/models/person'

describe MassiveRecord::ORM::IdFactory::AtomicIncrementation do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  subject { described_class.instance }

  it_should_behave_like "an id factory"


  it "has table name equal to id_factories" do
    described_class.table_name.should eq "id_factories_test"
  end

  describe "#next_for" do
    after do
      MassiveRecord::ORM::IdFactory::AtomicIncrementation.destroy_all
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

    it "autoload ids as integers" do
      subject.next_for(Person).should eq 1

      family_for_person = subject.class.column_families.family_by_name(MassiveRecord::ORM::IdFactory::AtomicIncrementation::COLUMN_FAMILY_FOR_TABLES)
      field_for_person = family_for_person.fields.delete_if { |f| f.name == Person.table_name }

      subject.reload
      subject.attributes_schema[Person.table_name].type.should eq :integer
    end


    describe "old string representation of integers" do
      it "increments correctly when value is '1'" do
        old_ensure = MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings
        MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings = true

        subject.next_for(Person)

        # Enter incompatible data, number as string.
        MassiveRecord::ORM::IdFactory::AtomicIncrementation.table.first.tap do |row|
          row.update_column(
            MassiveRecord::ORM::IdFactory::AtomicIncrementation::COLUMN_FAMILY_FOR_TABLES,
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
