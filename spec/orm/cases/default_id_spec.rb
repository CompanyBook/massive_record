require 'spec_helper'
require 'orm/models/model_without_default_id'

describe ModelWithoutDefaultId do
  #include MockMassiveRecordConnection
  include SetUpHbaseConnectionBeforeAll
  #include SetTableNamesToTestTable

  context "with auto increment id" do
    its(:id) { be_nil }
    its(:set_id_from_factory_before_create) { be_true }

    it "sets id to what next_id returns" do
      MassiveRecord::ORM::IdFactory::AtomicIncrementation.should_receive(:next_for).and_return 1
      subject.save
      subject.id.should eq "1"
    end

    it "does nothing if the id is set before create" do
      subject.id = 2
      MassiveRecord::ORM::IdFactory::AtomicIncrementation.should_not_receive(:next_for)
      subject.save
      subject.id.should eq "2"
    end

    it "is configurable which factory to use" do
      id_factory_was = ModelWithoutDefaultId.id_factory
      ModelWithoutDefaultId.id_factory = MassiveRecord::ORM::IdFactory::Timestamp

      MassiveRecord::ORM::IdFactory::Timestamp.should_receive(:next_for).and_return 123
      subject.save
      subject.id.should eq "123"

      ModelWithoutDefaultId.id_factory = MassiveRecord::ORM::IdFactory::AtomicIncrementation
    end
  end

  context "without auto increment id" do
    before(:all) { subject.class.set_id_from_factory_before_create = false }
    after(:all) { subject.class.set_id_from_factory_before_create = true }

    its(:id) { be_nil }
    its(:set_id_from_factory_before_create) { be_false }

    it "raises error as expected when id is missing" do
      expect { subject.save }.to raise_error MassiveRecord::ORM::IdMissing
    end
  end

  it "is AtomicIncrementation on ORM::Table" do
    Person.id_factory.instance.should be_instance_of MassiveRecord::ORM::IdFactory::AtomicIncrementation
  end

  it "is Timestamp on ORM::Embedded" do
    Address.id_factory.instance.should be_instance_of MassiveRecord::ORM::IdFactory::Timestamp
  end
end
