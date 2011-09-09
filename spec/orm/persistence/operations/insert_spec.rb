require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Insert do
  include MockMassiveRecordConnection

  let(:record) { TestClass.new("id-1") }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }

  it_should_behave_like "a persistence table operation class"


  describe "#execute" do
    it "ensures that we have table and column families" do
      record.class.should_receive(:ensure_that_we_have_table_and_column_families!)
      subject.execute
    end

    it "raises a RecordNotUnique error if we should check it" do
      record.class.should_receive(:check_record_uniqueness_on_create).and_return true 
      record.class.should_receive(:exists?).with(record.id).and_return true
      expect { subject.execute }.to raise_error MassiveRecord::ORM::RecordNotUnique
    end

    it "calls upon store_record_to_database for help with actually insert job" do
      subject.should_receive(:store_record_to_database).with('create')
      subject.execute
    end
  end
end
