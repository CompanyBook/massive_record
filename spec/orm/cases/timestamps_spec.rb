require 'spec_helper'
require 'orm/models/person'
require 'orm/models/person_with_timestamp'
require 'orm/models/address'
require 'orm/models/address_with_timestamp'

describe "timestamps" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  describe "on table classes" do
    let(:attribute_to_be_changed) { 'name' }

    describe PersonWithTimestamp do
      subject { PersonWithTimestamp.create!(:name => "John Doe", :email => "john@base.com", :age => "20").reload }

      it_should_behave_like "a model with timestamps"
    end

    describe Person do
      subject { Person.create!(:name => "John Doe", :email => "john@base.com", :age => "20").reload }

      it_should_behave_like "a model without timestamps"
    end
  end


  describe "on embedded classes" do
    let(:attribute_to_be_changed) { 'street' }
    let(:person) { Person.create!(:name => "John Doe", :email => "john@base.com", :age => "20").reload }

    describe AddressWithTimestamp do
      subject { AddressWithTimestamp.new "id1", :street => "Karl Johans gate 13" }
      before { person.addresses_with_timestamp << subject }

      it_should_behave_like "a model with timestamps"
    end

    describe Address do
      subject { Address.new "id1", :street => "Karl Johans gate 13" }
      before { person.addresses << subject }

      it_should_behave_like "a model without timestamps"
    end
  end
end
