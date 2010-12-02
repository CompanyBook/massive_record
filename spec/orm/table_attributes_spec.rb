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
      @person.attributes.class.should == Hash
      @person.attributes.keys.sort.should == [:first_name, :last_name, :email, :date_of_birth, :status].sort
    end
    
    it "should set a value" do
      @person.first_name = "John"
      @person.first_name.should == "John"
    end
    
    it "should have a private attributes setter" do
      @person.respond_to?("attributes=").should be_false 
    end
    
    it "should mass assign values" do
      @person.send(:attributes=, { :first_name => "John", :last_name => "Doe" })
      @person.first_name.should == "John"
      @person.last_name.should == "Doe"
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
      @person.date_of_birth.class.should == Date
    end
    
    it "should parse Boolean format" do
      @person.status.should be_true
    end
    
  end
    
end
