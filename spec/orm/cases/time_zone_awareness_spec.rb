require 'spec_helper'
require 'orm/models/test_class'
require 'orm/models/person'

describe "Time zone awareness" do
  subject { TestClass.new }


  describe "configuration" do
    it "should have a default time zone configuration" do
      TestClass.default_timezone.should eq :local
    end

    it "should have default time zone awareness to false" do
      TestClass.time_zone_aware_attributes.should eq false
    end

    it "should by default skip no attributes when doing time zone conversions" do
      TestClass.skip_time_zone_conversion_for_attributes.should eq []
    end

    it "should be possible to skip some attributes in TestClass while Person is untuched" do
      TestClass.skip_time_zone_conversion_for_attributes = [:test]
      TestClass.skip_time_zone_conversion_for_attributes.should include :test
      Person.skip_time_zone_conversion_for_attributes.should be_empty
    end
  end
end
