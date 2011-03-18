require 'spec_helper'
require 'orm/models/friend'
require 'orm/models/best_friend'

describe "Single table inheritance" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  [Friend, BestFriend, BestFriend::SuperBestFriend].each do |klass|
    describe klass do
      let(:subject) { klass.new(:id => "ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true) }

      its(:type) { should == klass.to_s }

      it "should instantiate correct class when reading from database" do
        subject.save!
        Person.find(subject.id).should == subject
      end
    end
  end
end
