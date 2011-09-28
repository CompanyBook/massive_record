
require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Embedded::Reload do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:record) { Address.new("addresss-id", :street => "Asker", :number => 5) }
  let(:person) { Person.new "person-id", :name => "Thorbjorn", :age => "22" }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }

  before { record.person = person; record.save! }

  describe "generic behaviour" do
    it_should_behave_like "a persistence embedded operation class"
  end


  describe "#execute" do
    context "new record" do
      before { record.stub(:persisted?).and_return false }

      its(:execute) { should be_false }
    end

    context "persisted" do
      let(:inverse_proxy) { mock(Object, :reload => true, :find => record) }
      let(:embedded_in_proxy) { subject.embedded_in_proxies.first }

      before do
        subject.stub(:inverse_proxy_for).and_return(inverse_proxy)
      end

      it "raises error if unsupported numbers of embedded in relations" do
        subject.should_receive(:embedded_in_proxies).any_number_of_times.and_return [1, 2]
        expect { subject.execute }.to raise_error MassiveRecord::ORM::Persistence::Operations::Embedded::Reload::UnsupportedNumberOfEmbeddedIn
      end

      it "asks for inverse proxy" do
        subject.should_receive(:inverse_proxy_for).with(embedded_in_proxy).and_return(inverse_proxy)
        subject.execute
      end

      it "reloads inverse proxy" do
        inverse_proxy.should_receive :reload
        subject.execute
      end

      it "finds the record asked to be reloaded" do
        inverse_proxy.should_receive(:find).with(record.id).and_return record
        subject.execute
      end

      it "reinit record with found record's attributes and raw_data" do
        record.should_receive(:attributes).and_return('attributes' => {})
        record.should_receive(:raw_data).and_return('raw_data' => {})
        record.should_receive(:reinit_with).with({
          'attributes' => {'attributes' => {}},
          'raw_data' => {'raw_data' => {}}
        })
        subject.execute
      end
    end
  end
end
