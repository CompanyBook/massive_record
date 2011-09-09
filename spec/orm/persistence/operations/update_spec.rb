require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Update do
  include MockMassiveRecordConnection

  let(:record) { TestClass.new("id-1") }
  let(:options) { {:attribute_names_to_update => ['foo']} }
  
  subject { described_class.new(record, options) }

  it_should_behave_like "a persistence table operation class"


  describe "#execute" do
    it "ensures that we have table and column families" do
      subject.should_receive(:ensure_that_we_have_table_and_column_families!)
      subject.execute
    end

    it "calls upon store_record_to_database for help with actually update job" do
      subject.should_receive(:store_record_to_database).with('update', ['foo'])
      subject.execute
    end
  end
end
