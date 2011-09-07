require 'spec_helper'
require 'orm/models/person'
require 'orm/models/test_class'

describe "table classes" do
  before do
    @subject = MassiveRecord::ORM::Table
    
    @subject.column_family(:info) do
      field :first_name
      field :last_name
    end
    
    @subject.column_family(:misc) do
      field :status, :boolean, :default => false
    end
    
    @subject.column_family(:sandbox) do
      autoload_fields
    end
  end

  after do
    @subject.column_families = nil
  end
  
  describe "column_families" do
    it "should have a collection of column families" do
      @subject.column_families.should be_a_kind_of(Set)
    end
    
    it "should have an attributes schema" do
      @subject.attributes_schema.should include("first_name", "last_name", "status")
    end
  end
end

describe "Person which is a table" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  before do
    @person = Person.new
    @person.id = "test"
    @person.points = "25"
    @person.date_of_birth = "19850730"
    @person.status = "0"
  end
  
  it "should have a list of column families" do
    Person.column_families.collect(&:name).should include("info")
  end

  it "should keep different column families per sub class" do
    Person.column_families.collect(&:name).should include "info", "base"
    TestClass.column_families.collect(&:name).should == ["test_family"]
  end
  
  it "should have a list of attributes created from the column family 'info'" do
    @person.attributes.keys.should include("name", "email", "points", "date_of_birth", "status")
  end
  
  it "should default an attribute to its default value" do
    @person.points.should == 25
  end
  
  it "should parse a Date field properly" do
    @person.date_of_birth.should be_a_kind_of(Date)
  end
  
  it "should parse a Boolean field properly" do
    @person.status.should be_false
  end

  it "should decode/encode empty hashes correctly" do
    @person.addresses = {}
    @person.save! :validate => false
    @person.reload
    @person.addresses.should be_instance_of Hash
  end
end
