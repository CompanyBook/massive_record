require 'spec_helper'
require 'orm/models/address'

describe MassiveRecord::ORM::Embedded do
  subject { Address.new(:street => "Asker", :number => 5) }
  let(:person) { Person.new "person-id", :name => "Thorbjorn", :age => "22" }

  it "should have known_attribute_names" do
    Address.should have(4).known_attribute_names
    Address.known_attribute_names.should include("street", "number", "nice_place")
  end

  it "should have default_attributes_from_schema" do
    Address.default_attributes_from_schema["street"].should be_nil
    Address.default_attributes_from_schema["number"].should be_nil
    Address.default_attributes_from_schema["nice_place"].should be_true
  end

  it "should have attributes_schema" do
    Address.attributes_schema["street"].should be_instance_of MassiveRecord::ORM::Schema::Field
  end

  it "should have a default value set" do
    subject.nice_place.should be_true
  end


  # TODO  We might want to remove this when we have implemented
  #       associations correctly. Since Columns are contained within
  #       tables, calling save should do something on it's proxy_owner object.
  describe "not be possible to persist (at least for now...)" do
    %w(first last all exists? destroy_all).each do |method|
      it "should not respond to class method #{method}" do
        Address.should_not respond_to method
      end
    end

    %w(
      reload save save! save
      update_attribute update_attributes update_attributes! touch destroy
      delete increment! decrement! atomic_increment! atomic_decrement!
    ).each do |method|
      it "do respond to #{method}" do
        subject.should respond_to method
      end
    end
  end


  describe "persistence" do
    include SetUpHbaseConnectionBeforeAll 
    include SetTableNamesToTestTable

    describe "#save" do
      context "not embedded" do
        before { subject.person = nil }

        it "raises error" do
          expect { subject.save }.to raise_error MassiveRecord::ORM::NotAssignedToEmbeddedCollection
        end
      end

      context "embedded in a collection" do
        context "collection owner not persisted" do
          before { subject.person = person }

          it "gets assigned an id" do
            subject.save
            subject.id.should_not be_blank
          end

          it "saves both embedded record and embedded in record" do
            subject.save

            person.should be_persisted
            subject.should be_persisted
          end

          it "does nothing if validations fail on embedded" do
            subject.street = nil
            subject.save
            subject.errors.should_not be_empty

            person.should_not be_persisted
            subject.should_not be_persisted
          end

          describe "validations fails on owner" do
            before { person.name = nil }

            it "does not persist owner" do
              subject.save
              person.should_not be_persisted
            end

            it "does not mark embedded as persisted" do
              subject.save
              subject.should_not be_persisted
            end
          end
        end

        context "colletion owner persisted" do
          before do
            person.save!
            subject.person = person
          end

          it "gets assigned an id" do
            subject.id.should_not be_blank
          end

          it "persists address" do
            subject.street = "new_address"
            subject.save
            person.reload.addresses.first.street.should eq "new_address"
          end

          it "will not save changes in owner when embedded is saved" do
            subject.street += "_NEW"
            person.name += "_NEW"

            subject.save

            person.should be_name_changed
          end

          it "does nothing if validations fail on embedded" do
            subject.street = nil
            subject.save
            subject.errors.should_not be_empty

            subject.should be_changed
          end

          it "save even if validations fails on owner of collection embedded in" do
            person.name = nil
            subject.street += "_NEW"
            subject.save

            subject.should_not be_changed
          end
        end
      end
    end


    describe "#destroy" do
      context "not emedded" do
        before { subject.person = nil }
        
        it "marks itself as destroyed" do
          subject.destroy
          subject.should be_destroyed
        end
      end

      context "embedded" do
        context "collection owner new record" do
          before { subject.person = person }

          it "marks itself as destroyed" do
            subject.destroy
            subject.should be_destroyed
          end
        end

        context "collection owner persisted" do
          before do
            subject.person = person
            person.save!
          end

          it "marks itself as destroyed" do
            subject.destroy
            subject.should be_destroyed
          end

          it "is removed from embeds_many collection" do
            subject.destroy
            person.addresses.should be_empty
          end

          it "is actually removed from collection" do
            subject.destroy
            person.reload.addresses.should be_empty
          end
        end
      end
    end
  end

  describe "id" do
    include SetUpHbaseConnectionBeforeAll 
    include SetTableNamesToTestTable

    describe "assignment on first save" do
      it "has no id when first instantiated" do
        subject.id.should be_nil
      end

      it "gets an id on explicit save" do
        subject.person = person
        subject.save
        subject.id.should_not be_nil
      end

      it "gets an id when saved through persisted parent" do
        person.save
        person.addresses << subject
        subject.id.should_not be_nil
      end
    end

    describe "#database_id" do
      let(:base_class) { Address.base_class.to_s.underscore }

      describe "reader" do
        it "has non when first instantiated" do
          subject.database_id.should be_nil
        end

        it "gets one on explicit save" do
          subject.person = person
          subject.save
          subject.database_id.should eq [base_class, subject.id].join(MassiveRecord::ORM::Embedded::DATABASE_ID_SEPARATOR)
        end

        it "gets one when saved through persisted parent" do
          person.save
          person.addresses << subject
          subject.database_id.should eq [base_class, subject.id].join(MassiveRecord::ORM::Embedded::DATABASE_ID_SEPARATOR)
        end
      end

      describe "writer" do
        it "splits base_class and id and assigns id to id" do
          subject.database_id = "address#{MassiveRecord::ORM::Embedded::DATABASE_ID_SEPARATOR}166"
          subject.id.should eq "166"
        end

        it "raises an error if database id could not be parsed" do
          expect {
            subject.database_id = "address-166"
          }.to raise_error MassiveRecord::ORM::InvalidEmbeddedDatabaseId
        end
      end
    end
  end
end
