require 'spec_helper'

describe MassiveRecord::ORM::Table do
  
  before do
    @connection ||= MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
  end
  
  describe "and a new Person instance" do
    
    before do
      @person = Person.new
    end
    
    it "should fail to save without any attributes" do
      @person.save.should be_false
    end
        
    it "should return a nil ID" do
      @person.id.should be_nil
    end
    
    it "should a list of the available attributes" do
      @person.attributes.should be_instance_of Hash
      @person.attributes.keys.should include *%w(name email date_of_birth status)
    end
    
    it "should set a value" do
      @person.name = "John"
      @person.name.should == "John"
    end
    
    it "should mass assign values" do
      @person.attributes = {:name => "Foo", :age => 55}
      @person.name.should == "Foo"
      @person.age.should == 55
    end
  end
  
  describe "and an existing Person instance" do
    
    before do
      @person = Person.new({
        :first_name => "John",
        :last_name => "Doe",
        :email => "john@doe.com",
        :date_of_birth => "Fri, 30 Nov 1990",
        :status => "1"
      })
      
      @person.id = "ID1"
    end
    
    it "should have an ID" do
      @person.id.should == "ID1"
    end
    
    it "should have 5 attributes" do
      @person.attributes.size == 5
    end
    
    it "should parse Date format" do
      pending "casting is not in place, yet."
      @person.date_of_birth.should be_instance_of Date
    end
    
    it "should parse Boolean format" do
      @person.status.should be_true
    end
    
  end
    
end
