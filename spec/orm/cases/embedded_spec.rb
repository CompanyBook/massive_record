require 'spec_helper'
require 'orm/models/address'

describe MassiveRecord::ORM::Embedded do
  subject { Address.new("addresss-id", :street => "Asker", :number => 5) }

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

    let(:person) { Person.new "person-id", :name => "Thorbjorn", :age => "22" }

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

          it "saves both embedded record and embedded in record" do
            subject.save

            person.should be_persisted
            subject.should be_persisted
          end
        end

        context "colletion owner persisted" do
          before do
            person.save!
            subject.person = person
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

          it "is actually removed from collection" do
            subject.destroy
            person.reload.addresses.should be_empty
          end
        end
      end
    end
  end
end
