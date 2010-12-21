require 'spec_helper'

describe "id factory" do
  it "should be a singleton" do
    MassiveRecord::ORM::IdFactory.included_modules.should include(Singleton)
  end
end
