require 'spec_helper'
require 'orm/models/test_class'
require 'orm/models/person'

describe "Time zone awareness" do
  def in_time_zone(tz)
    old_zone = Time.zone
    old_awareness = MassiveRecord::ORM::Base.time_zone_aware_attributes

    Time.zone = zone ? ActiveSupport::TimeZone[zone] : nil
    MassiveRecord::ORM::Base.time_zone_aware_attributes = !zone.nil?

    yield

    ensure
      Time.zone = old_zone
      MassiveRecord::ORM::Base.time_zone_aware_attributes = old_awareness
  end




  before { MassiveRecord::ORM::Base.time_zone_aware_attributes = true }

  describe "configuration" do
    it "should have a default time zone configuration" do
      TestClass.default_timezone.should eq :local
    end

    it "should have default time zone awareness" do
      TestClass.time_zone_aware_attributes.should eq true
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


  describe "when to do conversion" do
    let(:field) { MassiveRecord::ORM::Schema::Field.new :name => 'tested_at' }

    it "should do conversion when attribute is time" do
      field.type = :time
      TestClass.send(:time_zone_conversion_on_field?, field).should be_true
    end

    it "should not do conversion if time_zone_aware_attributes is false" do
      field.type = :time
      TestClass.time_zone_aware_attributes = false
      TestClass.send(:time_zone_conversion_on_field?, field).should be_false
    end

    it "should not do conversion when attribute name is included in skip list" do
      field.type = :time
      TestClass.skip_time_zone_conversion_for_attributes = ['tested_at']
      TestClass.send(:time_zone_conversion_on_field?, field).should be_false
    end

    it "should not do conversion when attribute is string field" do
      field.type = :string
      TestClass.send(:time_zone_conversion_on_field?, field).should be_false
    end
  end



  describe "conversion on attribute" do
    subject { TestClass.new }
    let(:zone) { "Europe/Stockholm" }
    let(:time_as_string) { "2010-10-10 10:10:10" }

    it "should be nil when set to nil" do
      in_time_zone zone do
        subject.tested_at = nil
        subject.tested_at.should be_nil
      end
    end

    it "should return time as TimeWithZone" do
      in_time_zone zone do
        subject.tested_at = time_as_string
        subject.tested_at.should be_instance_of ActiveSupport::TimeWithZone
      end
    end
  end
end
