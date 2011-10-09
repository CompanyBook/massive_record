require 'spec_helper'
require 'orm/models/callback_testable'
require 'orm/models/person'
require 'orm/models/address'

#
# Some basic tests
#
shared_examples_for "Massive Record with callbacks" do
  it "should include ActiveModel::Callbacks" do
    described_class.should respond_to :define_model_callbacks
  end

  it "should include ActiveModell::Validations::Callback" do
    described_class.included_modules.should include(ActiveModel::Validations::Callbacks)
  end
end

[Person, Address].each do |klass|
  describe klass do
    it_should_behave_like "Massive Record with callbacks"
  end
end


#
# Some real life object tests
#
class CallbackDeveloperTable < MassiveRecord::ORM::Table
  include CallbackTestable
end

describe CallbackDeveloperTable do
  it_should_behave_like "a model with callbacks"
end
