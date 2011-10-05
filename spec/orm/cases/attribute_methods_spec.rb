require 'spec_helper'
require 'orm/models/person'

describe "attribute methods" do
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
  end
end
