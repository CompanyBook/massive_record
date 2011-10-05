require 'spec_helper'
require 'orm/models/person'

describe "attribute methods" do
  include TimeZoneHelper

  subject { Person.new "5", :name => "John", :age => "15" }

  it "should define reader method" do
    subject.name.should == "John"
  end

  it "should define writer method" do
    subject.name = "Bar"
    subject.name.should == "Bar"
  end

  it "should be possible to write attributes" do
    subject.write_attribute :name, "baaaaar"
    subject.name.should == "baaaaar"
  end


  it "converts correcly written floats as string to float on write" do
    subject.write_attribute(:carma, "1.5")
    subject.carma.should eq 1.5
  end

  it "converts baldy written floats as string to float on write" do
    subject.write_attribute(:carma, "1.5f")
    subject.carma.should eq 1.5
  end

  it "keeps nil when assigned to float" do
    subject.write_attribute(:carma, nil)
    subject.carma.should eq nil
  end

  it "keeps empty string when assigned to float" do
    subject.write_attribute(:carma, "")
    subject.carma.should eq nil
  end

  it "converts correcly written integers as string to integer on write" do
    subject.write_attribute(:points, "1")
    subject.points.should eq 1
  end

  it "converts baldy written integers as string to integer on write" do
    subject.write_attribute(:points, "1f")
    subject.points.should eq 1
  end

  it "keeps nil when assigned to integer" do
    subject.write_attribute(:points, nil)
    subject.points.should eq nil
  end

  it "keeps empty string when assigned to integer" do
    subject.write_attribute(:points, "")
    subject.points.should eq nil
  end





  it "should be possible to read attributes" do
    subject.read_attribute(:name).should == "John"
  end

  it "should return casted value when read" do
    subject.read_attribute(:age).should == 15
  end

  it "should read from a method if it has been defined" do
    subject.should_receive(:_name).and_return("my name is")
    subject.read_attribute(:name).should eq "my name is"
  end
  
  describe "#attributes" do
    it "should contain the id" do
      subject.attributes.should include("id")
    end

    it "should not return @attributes directly" do
      subject.attributes.object_id.should_not == subject.instance_variable_get(:@attributes).object_id
    end

    it "should ask read_attribute for help" do
      subject.should_receive(:read_attribute).any_number_of_times.and_return("stub")
      subject.attributes['name'].should eq 'stub'
    end
  end

  describe "#attributes=" do
    it "should simply return if incomming value is not a hash" do
      subject.attributes = "FOO BAR"
      subject.attributes.keys.should include("name")
    end

    it "should mass assign attributes" do
      subject.attributes = {:name => "Foo", :age => 20}
      subject.name.should == "Foo"
      subject.age.should == 20
    end

    it "should raise an error if we encounter an unkown attribute" do
      lambda { subject.attributes = {:unkown => "foo"} }.should raise_error MassiveRecord::ORM::UnknownAttributeError
    end

    describe "multiparameter" do
      describe "date" do
        let(:date) { Date.new 1981, 8, 20 }
        let(:params) do
          {
            "date_of_birth(1i)" => date.year.to_s,
            "date_of_birth(2i)" => date.month.to_s,
            "date_of_birth(3i)" => date.day.to_s
          }
        end

        it "parses a complete multiparameter" do
          subject.attributes = params
          subject.date_of_birth.should eq date
        end

        it "parses when year is missing" do
          params["date_of_birth(1i)"] = ""
          subject.attributes = params
          subject.date_of_birth.should eq Date.new(1, date.month, date.day)
        end

        it "parses when month is missing" do
          params["date_of_birth(2i)"] = ""
          subject.attributes = params
          subject.date_of_birth.should eq Date.new(date.year, 1, date.day)
        end

        it "parses when day is missing" do
          params["date_of_birth(3i)"] = ""
          subject.attributes = params
          subject.date_of_birth.should eq Date.new(date.year, date.month, 1)
        end

        it "sets to nil if all are blank" do
          params["date_of_birth(1i)"] = ""
          params["date_of_birth(2i)"] = ""
          params["date_of_birth(3i)"] = ""
          subject.attributes = params
          subject.date_of_birth.should be_nil
        end

        it "sets to nil if any of the values are on wrong format" do
          params["date_of_birth(3i)"] = "foobar"
          subject.attributes = params
          subject.date_of_birth.should be_nil
        end
      end

      describe "time" do
        let(:time) { Time.new 2011, 8, 20, 17, 30, 0 }
        let(:tz_europe) { "Europe/Stockholm" }
        let(:tz_us) { "Pacific Time (US & Canada)" }

        let(:params) do
          {
            "last_signed_in_at(1i)" => time.year.to_s,
            "last_signed_in_at(2i)" => time.month.to_s,
            "last_signed_in_at(3i)" => time.day.to_s,
            "last_signed_in_at(4i)" => time.hour.to_s,
            "last_signed_in_at(5i)" => time.min.to_s,
            "last_signed_in_at(6i)" => time.sec.to_s
          }
        end

        it "parses complete multiparameter" do
          subject.attributes = params
          subject.last_signed_in_at.should eq time
        end

        it "parses complete multiparameter with time zone" do
          in_time_zone tz_us do
            subject.attributes = params
            subject.last_signed_in_at.should eq time.in_time_zone(tz_us)
          end
        end

        it "parses an old time" do
          year = 1835
          params["last_signed_in_at(1i)"] = year.to_s
          subject.attributes = params
          subject.last_signed_in_at.should eq Time.new(
            year, time.month, time.day,
            time.hour, time.min, time.sec
          )
        end

        it "parses when year is missing" do
          params["last_signed_in_at(1i)"] = ""
          subject.attributes = params
          subject.last_signed_in_at.should eq Time.new(
            0, time.month, time.day,
            time.hour, time.min, time.sec
          )
        end

        it "parses when hour is missing" do
          params["last_signed_in_at(4i)"] = ""
          subject.attributes = params
          subject.last_signed_in_at.should eq Time.new(
            time.year, time.month, time.day,
            0, time.min, time.sec
          )
        end

        it "parses when seconds is missing" do
          params["last_signed_in_at(6i)"] = ""
          subject.attributes = params
          subject.last_signed_in_at.should eq Time.new(
            time.year, time.month, time.day,
            time.hour, time.min, 0
          )
        end

        it "sets to nil if all are blank" do
          params["last_signed_in_at(1i)"] = ""
          params["last_signed_in_at(2i)"] = ""
          params["last_signed_in_at(3i)"] = ""
          params["last_signed_in_at(4i)"] = ""
          params["last_signed_in_at(5i)"] = ""
          params["last_signed_in_at(6i)"] = ""
          subject.attributes = params
          subject.last_signed_in_at.should eq nil
        end

        it "sets to nil if any of the values are on wrong format" do
          params["last_signed_in_at(3i)"] = "foobar"
          subject.attributes = params
          subject.last_signed_in_at.should be_nil
        end
      end
    end
  end
end
