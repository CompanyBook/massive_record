require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Embedded::Insert do
  include MockMassiveRecordConnection

  let(:record) { Address.new("addresss-id", :street => "Asker", :number => 5) }
  let(:person) { Person.new "person-id", :name => "Thorbjorn", :age => "22" }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }

  it_should_behave_like "a persistence embedded operation class"


  describe "#execute" do
    it "raises an error if any of the embedded_in relations are missing" do
      expect { subject.execute }.to raise_error MassiveRecord::ORM::NotAssignedToEmbeddedCollection
    end
  end
end
