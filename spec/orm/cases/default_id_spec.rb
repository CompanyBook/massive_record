require 'spec_helper'
require 'orm/models/model_without_default_id'

describe ModelWithoutDefaultId do
  include MockMassiveRecordConnection
  #include SetUpHbaseConnectionBeforeAll
  #include SetTableNamesToTestTable

  context "with auto increment id" do
    its(:id) { be_nil }
    its(:auto_increment_id) { be_true }

    it "sets id to what next_id returns" do
      subject.should_receive(:next_id).and_return 1
      subject.save
      subject.id.should eq "1"
    end

    it "does nothing if the id is set before create" do
      subject.id = 2
      subject.should_not_receive(:next_id)
      subject.save
      subject.id.should eq "2"
    end
  end

  context "without auto increment id" do
    before(:all) { subject.class.auto_increment_id = false }
    after(:all) { subject.class.auto_increment_id = true }

    its(:id) { be_nil }
    its(:auto_increment_id) { be_false }

    it "raises error as expected when id is missing" do
      expect { subject.save }.to raise_error MassiveRecord::ORM::IdMissing
    end
  end
end
