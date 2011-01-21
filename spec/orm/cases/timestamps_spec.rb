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
  end
end
