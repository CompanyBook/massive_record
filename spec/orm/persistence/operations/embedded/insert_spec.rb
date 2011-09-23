require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Embedded::Insert do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:record) { Address.new("addresss-id", :street => "Asker", :number => 5) }
  let(:person) { Person.new "person-id", :name => "Thorbjorn", :age => "22" }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }

  describe "generic behaviour" do
    before { record.person = person }
    it_should_behave_like "a persistence embedded operation class"
  end


  describe "#execute" do
    before { record.person = nil }

    context "not embedded" do
      it "raises an error" do
        expect { subject.execute }.to raise_error MassiveRecord::ORM::NotAssignedToEmbeddedCollection
      end
    end

    context "embedded" do
      context "but embedded in is not saved" do
        before { record.person = person }

        it "calls save on embedded owner when it is a new record" do
          person.should_receive(:save)
          subject.execute
        end

        it "is changed when reloading" do
          subject.execute
          Person.find(person.id).addresses.first.should eq record
        end
      end

      context "and embedded in is already saved and now needs to be updated" do
        # Not gonna get into this situation as far as I can see now.
        # Reason for it is we are auto-saving when pushing new records
        # on to an embeds many collection where it's owner has been persisted.
        # But, it might be something we want to handle in the future if we have
        # an auto_save option on the relation. In which case I think we should
        # ensure that only the one embedded record which receives save are actually
        # updated in the embeds many collection owner's record.
      end
    end
  end
end
