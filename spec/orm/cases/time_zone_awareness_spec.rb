require 'spec_helper'
require 'orm/models/test_class'
require 'orm/models/person'

describe "Time zone awareness" do
  include TimeZoneHelper

  describe "configuration" do
    it "should have a default time zone configuration" do
      TestClass.default_timezone.should eq :local
    end

    it "should have default time zone awareness" do
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


  describe "when to do conversion" do
    let(:field) { MassiveRecord::ORM::Schema::Field.new :name => 'tested_at' }

    it "should do conversion when attribute is time" do
      in_time_zone "utc" do
        field.type = :time
        TestClass.send(:time_zone_conversion_on_field?, field).should be_true
      end
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
      TestClass.skip_time_zone_conversion_for_attributes = []
    end

    it "should not do conversion when attribute is string field" do
      field.type = :string
      TestClass.send(:time_zone_conversion_on_field?, field).should be_false
    end
  end



  describe "conversion on attribute" do
    include SetUpHbaseConnectionBeforeAll
    include SetTableNamesToTestTable

    subject { TestClass.new "test" }
    let(:tz_europe) { "Europe/Stockholm" }
    let(:tz_us) { "Pacific Time (US & Canada)" }

    let(:time_as_string) { "2010-10-10 10:10:10" }

    it "should be nil when set to nil" do
      in_time_zone tz_europe do
        subject.tested_at = nil
        subject.tested_at.should be_nil
      end
    end

    it "should return time as TimeWithZone when attribute accessed directly" do
      in_time_zone tz_europe do
        subject.tested_at = time_as_string
        subject.tested_at.should be_instance_of ActiveSupport::TimeWithZone
      end
    end

    it "should return time as TimeWithZone when attribute accessed through read_attribute" do
      in_time_zone tz_europe do
        subject.tested_at = time_as_string
        subject.read_attribute(:tested_at).should be_instance_of ActiveSupport::TimeWithZone
      end
    end

    it "should return time in local time" do
      in_time_zone tz_europe do
        subject.tested_at = time_as_string
        subject.tested_at.time_zone.should eq ActiveSupport::TimeZone[tz_europe]

        in_time_zone tz_us do
          subject.tested_at.time_zone.should eq ActiveSupport::TimeZone[tz_us]
        end
      end
    end

    it "should return correct time in other time zones" do
      utc_time = Time.utc(2010, 1, 1)
      us_time = utc_time.in_time_zone(tz_us)

      in_time_zone tz_europe do
        subject.tested_at = us_time
        subject.tested_at.should eq utc_time
      end
    end

    it "should return correct times after save" do
      utc_time = Time.now.utc
      europe_time = utc_time.in_time_zone(tz_europe)
      us_time = utc_time.in_time_zone(tz_us)

      in_time_zone tz_europe do
        subject.tested_at = europe_time
        subject.save!
      end

      subject.reload

      in_time_zone tz_us do
        subject.tested_at.to_s.should eq us_time.to_s
      end
    end

    it "should store time in DB format" do
      utc_time = Time.now.utc
      europe_time = utc_time.in_time_zone(tz_europe)

      in_time_zone tz_europe do
        subject.tested_at = europe_time
        subject.save!
      end

      subject.reload
      subject.tested_at.to_s.should eq utc_time.to_s

      in_time_zone tz_europe do
        subject.tested_at.to_s.should eq europe_time.to_s
      end
    end

    it "should store time in DB format, raw check" do
      in_time_zone tz_europe do
        subject.tested_at = time_as_string
        subject.save!

        r = TestClass.table.find("test")
        cell = r.columns["test_family:tested_at"]
        cell.value.should eq MassiveRecord::ORM::Base.coder.dump(Time.zone.parse(time_as_string).utc)
      end
    end
  end
end
