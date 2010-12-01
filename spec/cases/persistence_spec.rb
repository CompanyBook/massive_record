require 'spec_helper'
require 'models/basic'

describe "persistance" do
  it "should be a new record when calling new" do
    Basic.new.should be_new_record
  end

  it "should not be persisted when new record" do
    Basic.new.should_not be_persisted
  end

  it "should be persisted if saved" do
    basic = Basic.new
    basic.save
    basic.should be_persisted
  end

  it "should be destroyed when destroyed" do
    basic = Basic.new
    basic.save
    basic.destroy
    basic.should be_destroyed
  end

  it "should not be persisted if destroyed" do
    basic = Basic.new
    basic.save
    basic.destroy
    basic.should_not be_persisted
  end
end
