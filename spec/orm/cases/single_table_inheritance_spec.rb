require 'spec_helper'
require 'orm/models/friend'
require 'orm/models/best_friend'

describe "Single table inheritance" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  describe Friend do
    let(:subject) { Friend.new :id => "ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true }
  end


  describe "#base_class" do
    it "should return correct base class for direct descendant of Base" do
      Person.base_class.should == Person
    end

    it "should return Person when asking a descendant of Person" do
      Friend.base_class.should == Person
    end

    it "should return Person when asking a descendant of Person multiple levels" do
      BestFriend.base_class.should == Person
    end
  end


  it "first sub class should have the same table name as base class" do
    pending
    Friend.table_name.should == Person.table_name
  end

  it "second sub class should have the same table name as base class" do
    pending
    BestFriend.table_name.should == Person.table_name
  end
end
