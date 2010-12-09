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
  


  describe "#reload" do
    include CreatePersonBeforeEach

    before do
      @person = Person.find("ID1")
    end

    it "should reload models attribute" do
      original_name = @person.name
      @person.name = original_name + original_name
      @person.reload
      @person.name.should == original_name
    end

    it "should not be considered changed after reload" do
      original_name = @person.name
      @person.name = original_name + original_name
      @person.reload
      @person.should_not be_changed
    end

    it "should return self" do
      @person.reload.should == @person
    end

    it "should raise error on new record" do
      lambda { Person.new.reload }.should raise_error MassiveRecord::ORM::RecordNotFound
    end
  end
end
