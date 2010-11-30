require 'spec_helper'
require 'models/person'
require 'models/address'

shared_examples_for "validateable massive record model" do
  it "should include ActiveModel::Validations" do
    @model.class.included_modules.should include(ActiveModel::Validations)
  end

  it "should respond to valid?" do
    @model.should respond_to :valid?
  end
end





describe "MassiveRecord::Base::Table" do
  before do
    @model = Person.new
  end

  it_should_behave_like "validateable massive record model"
end

describe "MassiveRecord::Base::Column" do
  before do
    @model = Address.new
  end

  it_should_behave_like "validateable massive record model"
end
