require 'spec_helper'
require 'models/person'
require 'models/address'

shared_examples_for "Massive Record with callbacks" do
  it "should include ActiveModel::Callbacks" do
    @model.class.included_modules.should include(ActiveModel::Callbacks)
  end

  it "should include ActiveModell::Validations::Callback" do
    @model.class.included_modules.should include(ActiveModel::Validations::Callbacks)
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

    it_should_behave_like "Massive Record with callbacks"
  end
end
