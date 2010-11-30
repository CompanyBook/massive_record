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




{
  "MassiveRecord::Base::Table" => Person,
  "MassiveRecord::Base::Column" => Address
}.each do |orm_class, inherited_by_test_class|
  describe orm_class do
    before do
      @model = inherited_by_test_class.new
    end

    it_should_behave_like "validateable massive record model"
  end
end
