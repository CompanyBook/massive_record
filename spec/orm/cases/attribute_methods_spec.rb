require 'spec_helper'
require 'orm/models/person'

describe "attribute methods" do
  before do
    @model = Person.new "5", :name => "John", :age => "15"
  end

  it "should define reader method" do
    @model.name.should == "John"
  end

  it "should define writer method" do
    @model.name = "Bar"
    @model.name.should == "Bar"
  end

  it "should be possible to write attributes" do
    @model.write_attribute :name, "baaaaar"
    @model.name.should == "baaaaar"
  end


  it "converts correcly written floats as string to float on write" do
    @model.write_attribute(:carma, "1.5")
    @model.carma.should eq 1.5
  end

  it "converts baldy written floats as string to float on write" do
    @model.write_attribute(:carma, "1.5f")
    @model.carma.should eq 1.5
  end

  it "keeps nil when assigned to float" do
    @model.write_attribute(:carma, nil)
    @model.carma.should eq nil
  end

  it "keeps empty string when assigned to float" do
    @model.write_attribute(:carma, "")
    @model.carma.should eq nil
  end

  it "converts correcly written integers as string to integer on write" do
    @model.write_attribute(:points, "1")
    @model.points.should eq 1
  end

  it "converts baldy written integers as string to integer on write" do
    @model.write_attribute(:points, "1f")
    @model.points.should eq 1
  end

  it "keeps nil when assigned to integer" do
    @model.write_attribute(:points, nil)
    @model.points.should eq nil
  end

  it "keeps empty string when assigned to integer" do
    @model.write_attribute(:points, "")
    @model.points.should eq nil
  end





  it "should be possible to read attributes" do
    @model.read_attribute(:name).should == "John"
  end

  it "should return casted value when read" do
    @model.read_attribute(:age).should == 15
  end

  it "should read from a method if it has been defined" do
    @model.should_receive(:_name).and_return("my name is")
    @model.read_attribute(:name).should eq "my name is"
  end
  
  describe "#attributes" do
    it "should contain the id" do
      @model.attributes.should include("id")
    end

    it "should not return @attributes directly" do
      @model.attributes.object_id.should_not == @model.instance_variable_get(:@attributes).object_id
    end

    it "should ask read_attribute for help" do
      @model.should_receive(:read_attribute).any_number_of_times.and_return("stub")
      @model.attributes['name'].should eq 'stub'
    end
  end

  describe "#attributes=" do
    it "should simply return if incomming value is not a hash" do
      @model.attributes = "FOO BAR"
      @model.attributes.keys.should include("name")
    end

    it "should mass assign attributes" do
      @model.attributes = {:name => "Foo", :age => 20}
      @model.name.should == "Foo"
      @model.age.should == 20
    end

    it "should raise an error if we encounter an unkown attribute" do
      lambda { @model.attributes = {:unkown => "foo"} }.should raise_error MassiveRecord::ORM::UnknownAttributeError
    end
  end
end
