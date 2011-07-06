require 'spec_helper'
require 'orm/models/friend'
require 'orm/models/best_friend'

describe "Single table inheritance" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  [Friend, BestFriend, BestFriend::SuperBestFriend].each do |klass|
    describe klass do
      let(:subject) { klass.new("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true) }

      its(:type) { should == klass.to_s }

      it "instantiates correct class when reading from database via super class" do
        subject.save!
        Person.find(subject.id).should == subject
      end
    end
  end

  it "sets no type when saving base class" do
    person = Person.new "ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true
    person.type.should be_nil
  end

  describe "fetching and restrictions" do
    describe "#first" do
      it "returns nil if class found is a super class of look-up class" do
        Person.create!("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        Friend.first.should be_nil
      end

      it "returns record if class found is the look-up class" do
        person = Person.create!("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        Person.first.should eq person
      end

      it "returns record if class found is subclass of look up class" do
        friend = Friend.create!("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        Person.first.should eq friend
      end

      it "returns record if class found is subclass of look up class, when class is not base class" do
        best_friend = BestFriend.create!("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        Friend.first.should eq best_friend
      end
    end

    describe "#all" do
      it "returns [] if class found is a super class of look-up class" do
        Person.create!("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        Friend.all.should eq []
      end

      it "returns record if class found is the look-up class" do
        person = Person.create!("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        Person.all.should eq [person]
      end

      it "returns record if class found is subclass of look up class" do
        friend = Friend.create!("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        Person.all.should eq [friend]
      end

      it "returns record if class found is subclass of look up class, when class is not base class" do
        person = Person.create!("ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        friend = Friend.create!("ID2", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        best_friend = BestFriend.create!("ID3", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)

        Friend.all.tap do |result|
          result.should include friend, best_friend
          result.should_not include person
        end
      end
    end

    it "does not check kind of records if class is not STI enabled" do
      record = TestClass.create! :foo => 'wee'
      TestClass.should_not_receive(:ensure_only_class_or_subclass_of_self_are_returned)
      TestClass.first
    end
  end
end
