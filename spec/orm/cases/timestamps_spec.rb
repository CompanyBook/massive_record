require 'spec_helper'
require 'orm/models/person'

describe "timestamps" do
  include CreatePersonBeforeEach

  before do
    @person = Person.first
  end


  describe "#updated_at" do
    it "should have updated at equal to nil on new records" do
      Person.new.updated_at.should be_nil
    end

    it "should not be possible to set updated at" do
      lambda { @person.updated_at = Time.now }.should raise_error "Can't be set manually."
      lambda { @person['updated_at'] = Time.now }.should raise_error "Can't be set manually."
      lambda { @person.write_attribute(:updated_at, Time.now) }.should raise_error "Can't be set manually."
    end

    it "should have updated at on a persisted record" do
      @person.updated_at.should be_a_kind_of Time
    end

    it "should be included in the list of known_attribute_names_for_inspect" do
      @person.send(:known_attribute_names_for_inspect).should include 'updated_at'
    end

    it "should include updated_at in inspect" do
      @person.inspect.should include(%q{updated_at:})
    end

    it "should be updated after a save" do
      sleep(1)

      updated_at_was = @person.updated_at
      @person.update_attribute :name, "Should Give Me New Updated At"

      @person.updated_at.should_not == updated_at_was
    end

    it "should not be updated after a save which failed" do
      sleep(1)

      updated_at_was = @person.updated_at
      @person.name = nil

      @person.should_not be_valid

      @person.updated_at.should == updated_at_was
    end
  end
end
