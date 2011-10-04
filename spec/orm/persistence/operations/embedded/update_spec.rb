require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Embedded::Update do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:another_address) { Address.new("addresss-id-2", :street => "Asker too", :number => 5) }
  let(:record) { Address.new("addresss-id", :street => "Asker", :number => 5) }
  let(:person) { Person.new "person-id", :name => "Thorbjorn", :age => "22" }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }

  describe "generic behaviour" do
    before { record.person = person }
    it_should_behave_like "a persistence embedded operation class"
  end


  describe "#execute" do
    before do
      record.person = person
      person.save
    end

    context "not embedded" do
      it "raises an error" do
        record.person = nil
        expect { subject.execute }.to raise_error MassiveRecord::ORM::NotAssignedToEmbeddedCollection
      end
    end

    context "embedded" do
      it "do persist the changes" do
        record.street = "Oslogata"
        subject.execute
        person.reload.addresses.first.street.should eq "Oslogata"
      end

      it "does not update other embedded records" do
        person.addresses << another_address
        record.street = "Oslogata"
        another_address.street = "FooBar"

        subject.execute

        person.reload.addresses.find(another_address.id).street.should eq "Asker too"
      end

      it "does not update attributes on the record it is embedded in" do
        person.name += "_NEW"
        record.street = "Oslogata"

        subject.execute

        person.reload.name.should eq "Thorbjorn"
      end
    end
  end
end
