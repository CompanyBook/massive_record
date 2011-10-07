require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Reload do
  include MockMassiveRecordConnection

  let(:record) { TestClass.new("id-1") }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }

  it_should_behave_like "a persistence table operation class"

  before { record.save! }

  describe "#execute" do
    context "new record" do
      before { record.stub(:persisted?).and_return false }

      its(:execute) { should be_false }

      it "does no find" do
        subject.klass.should_not_receive(:find)
        subject.execute
      end
    end

    context "persisted" do
      its(:execute) { should be_true }

      it "asks class to find it's id" do
        subject.klass.should_receive(:find).with(record.id).and_return(record)
        subject.execute
      end

      it "reinit record with found record's attributes and raw_data" do
        subject.klass.should_receive(:find).with(record.id).and_return(record)
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

