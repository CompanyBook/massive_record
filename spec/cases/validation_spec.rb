require 'spec_helper'
require 'models/person'
require 'models/address'

shared_examples_for "validateable massive record model" do
  it "should include ActiveModel::Validations" do
    @model.class.included_modules.should include(ActiveModel::Validations)
  end

  describe "behaviour from active model" do
    it "should respond to valid?" do
      @model.should respond_to :valid?
    end

    it "should respond to errors" do
      @model.should respond_to :errors
    end

    it "should have one error" do
      @invalidate_model.call(@model)
      @model.valid?
      @model.should have(1).error
    end
  end
end


describe "MassiveRecord::Base::Table" do
  before do
    @model = Person.new :name => "Alice", :email => "alice@gmail.com", :age => 20
    @invalidate_model = Proc.new { |p| p.name = nil }
  end

  it_should_behave_like "validateable massive record model"
end

describe "MassiveRecord::Base::Column" do
  before do
    @model = Address.new :street => "Henrik Ibsens gate 1"
    @invalidate_model = Proc.new { |a| a.street = nil }
  end

  it_should_behave_like "validateable massive record model"
end
