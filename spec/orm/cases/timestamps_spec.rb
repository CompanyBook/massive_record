require 'spec_helper'
require 'orm/models/person'
require 'orm/models/person_with_timestamp'

describe "timestamps" do
  include TimeZoneHelper
  include CreatePersonBeforeEach

  before do
    @person = Person.first
  end


  describe "#updated_at" do
    it "should have updated at equal to nil on new records" do
      Person.new.updated_at.should be_nil
    end

    it "should not be possible to set updated at" do
      lambda { @person.updated_at = Time.now }.should raise_error MassiveRecord::ORM::CantBeManuallyAssigned
      lambda { @person['updated_at'] = Time.now }.should raise_error MassiveRecord::ORM::CantBeManuallyAssigned
      lambda { @person.write_attribute(:updated_at, Time.now) }.should raise_error MassiveRecord::ORM::CantBeManuallyAssigned
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

    context "with time zone awarenesswith zone enabled" do
      it "should return time with zone" do
        in_time_zone "Europe/Stockholm" do
          @person.updated_at.should be_instance_of ActiveSupport::TimeWithZone
        end
      end

      it "should be nil on new records" do
        in_time_zone "Europe/Stockholm" do
          Person.new.updated_at.should be_nil
        end
      end
    end
  end

  describe "#created_at" do
    before do
      @person_with_timestamp = PersonWithTimestamp.create! :name => "John Doe", :email => "john@base.com", :age => "20"
    end

    it "should have created at" do
      @person_with_timestamp.should be_set_created_at_on_create
    end

    it "should not have created at on create if model does not have created at" do
      @person.should_not be_set_created_at_on_create
    end

    it "should have updated at equal to nil on new records" do
      PersonWithTimestamp.new.created_at.should be_nil
    end

    it "should not be possible to set updated at" do
      lambda { @person_with_timestamp.created_at = Time.now }.should raise_error MassiveRecord::ORM::CantBeManuallyAssigned
      lambda { @person_with_timestamp['created_at'] = Time.now }.should raise_error MassiveRecord::ORM::CantBeManuallyAssigned
      lambda { @person_with_timestamp.write_attribute(:created_at, Time.now) }.should raise_error MassiveRecord::ORM::CantBeManuallyAssigned
    end

    it "should not raise cant-set-error if object has no timestamps" do
      lambda { @person.created_at = Time.now }.should_not raise_error MassiveRecord::ORM::CantBeManuallyAssigned
    end

    it "should have created_at on a persisted record" do
      @person_with_timestamp.created_at.should be_a_kind_of Time
    end

    it "should not alter created at on update" do
      created_at_was = @person_with_timestamp.created_at

      sleep(1)

      @person_with_timestamp.update_attribute :name, @person_with_timestamp.name + "NEW"
      @person_with_timestamp.created_at.should == created_at_was
    end

    it "should be included in the list of known_attribute_names_for_inspect" do
      @person_with_timestamp.send(:known_attribute_names_for_inspect).should include 'created_at'
    end

    it "should include created_at in inspect" do
      @person_with_timestamp.inspect.should include(%q{created_at:})
    end

    it "should not include created_at if object does not have it" do
      @person.send(:known_attribute_names_for_inspect).should_not include 'created_at'
    end

    it "should raise error if created_at is not time" do
      PersonWithTimestamp.attributes_schema['created_at'].type = :string

      lambda { PersonWithTimestamp.create! }.should raise_error "created_at must be of type time"

      PersonWithTimestamp.attributes_schema['created_at'].type = :time
    end
  end
end
