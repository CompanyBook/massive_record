require 'spec_helper'
require 'orm/models/address'

describe "column classes" do
  before do
    @address = Address.new(:street => "Asker", :number => 5)
  end

  it "should have known_attribute_names" do
    Address.should have(3).known_attribute_names
    Address.known_attribute_names.should include("street", "number", "nice_place")
  end

  it "should have default_attributes_from_schema" do
    Address.default_attributes_from_schema["street"].should be_nil
    Address.default_attributes_from_schema["number"].should be_nil
    Address.default_attributes_from_schema["nice_place"].should be_true
  end

  it "should have attributes_schema" do
    Address.attributes_schema["street"].should be_instance_of MassiveRecord::ORM::Schema::Field
  end

  it "should have a default value set" do
    @address.nice_place.should be_true
  end


  # TODO  We might want to remove this when we have implemented
  #       associations correctly. Since Columns are contained within
  #       tables, calling save should do something on it's proxy_owner object.
  describe "not be possible to persist (at least for now...)" do
    %w(first last all exists? destroy_all).each do |method|
      it "should not respond to class method #{method}" do
        Address.should_not respond_to method
      end
    end

    %w(
      create! create reload save save!
      update_attribute update_attributes update_attributes! touch destroy
      delete increment! atomic_increment! decrement!
    ).each do |method|
      it "should not respond to instance method #{method}" do
        @address.should_not respond_to method
      end
    end
  end
end
