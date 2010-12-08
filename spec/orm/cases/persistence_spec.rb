require 'spec_helper'
require 'orm/models/test_class'

describe "persistance" do
  it "should be a new record when calling new" do
    TestClass.new.should be_new_record
  end

  it "should not be persisted when new record" do
    TestClass.new.should_not be_persisted
  end

  it "should be persisted if saved" do
    model = TestClass.new
    model.save
    model.should be_persisted
  end

  it "should be destroyed when destroyed" do
    model = TestClass.new
    model.save
    model.destroy
    model.should be_destroyed
  end

  it "should not be persisted if destroyed" do
    model = TestClass.new
    model.save
    model.destroy
    model.should_not be_persisted
  end

  it "should be possible to create new objects" do
    TestClass.create.should be_persisted
  end

  it "should raise an error if validation fails on save!" do
    model = TestClass.new
    model.should_receive(:create_or_update).and_return(false)
    lambda { model.save! }.should raise_error MassiveRecord::ORM::RecordNotSaved
  end

  it "should respond to reload" do
    TestClass.new.should respond_to :reload
  end
end
