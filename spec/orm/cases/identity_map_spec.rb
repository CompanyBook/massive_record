require 'spec_helper'
require 'orm/models/test_class'
require 'orm/models/friend'
require 'orm/models/best_friend'

describe MassiveRecord::ORM::IdentityMap do
  before do
    MassiveRecord::ORM::IdentityMap.clear
    MassiveRecord::ORM::IdentityMap.enabled = true
  end

  after(:all) { MassiveRecord::ORM::IdentityMap.enabled = false }


  describe "class methods" do
    subject { described_class }

    describe "confirguration" do
      describe ".enabled" do
        context "when disabled" do
          before { MassiveRecord::ORM::IdentityMap.enabled = false }
          its(:enabled) { should be_false }
          its(:enabled?) { should be_false }
        end

        context "when enabled" do
          before { MassiveRecord::ORM::IdentityMap.enabled = true }
          its(:enabled) { should be_true }
          its(:enabled?) { should be_true }
        end
      end

      it ".use sets enabled to true, yield block and ensure to reset it to what it was" do
        MassiveRecord::ORM::IdentityMap.enabled = false

        MassiveRecord::ORM::IdentityMap.use do
          MassiveRecord::ORM::IdentityMap.should be_enabled
        end

        MassiveRecord::ORM::IdentityMap.should_not be_enabled
      end

      it ".without sets enabled to true, yield block and ensure to reset it to what it was" do
        MassiveRecord::ORM::IdentityMap.enabled = true

        MassiveRecord::ORM::IdentityMap.without do
          MassiveRecord::ORM::IdentityMap.should_not be_enabled
        end

        MassiveRecord::ORM::IdentityMap.should be_enabled
      end
    end

    describe "persistence" do
      let(:person) { Person.new "id1" }
      let(:friend) { Friend.new "id2" }
      let(:test_class) { TestClass.new "id2" }

      describe ".repository" do
        its(:repository) { should eq Hash.new }

        it "has values as a hash by default for any key" do
          subject.send(:repository)['some_class'].should eq Hash.new
        end
      end

      describe ".clear" do
        it "removes all values from repository" do
          subject.send(:repository)['some_class']['an_id'] = Object.new
          subject.clear
          subject.send(:repository).should be_empty
        end
      end

      describe ".get" do
        context "when it does not has the record" do
          it "returns nil" do
            subject.get(person.class, person.id).should be_nil
          end
        end

        context "when it has the record" do
          it "returns the record" do
            subject.add person
            subject.get(person.class, person.id).should eq person
          end

          it "returns a single table inheritance record" do
            subject.add friend
            subject.get(friend.class, friend.id).should eq friend
          end

          it "returns the correct record when they have the same id" do
            person.id = test_class.id = "same_id"

            subject.add(person)
            subject.add(test_class)

            subject.get(person.class, person.id).should eq person
            subject.get(test_class.class, "same_id").should eq test_class
          end
        end
      end

      describe ".add" do
        it "does not do anything if trying to add nil" do
          subject.add(nil).should be_nil
        end

        it "persists the record" do
          subject.add person
          subject.get(person.class, person.id).should eq person
        end

        it "persists a single table inheritance record" do
          subject.add friend
          subject.get(friend.class, friend.id).should eq friend
        end
      end

      describe ".remove" do
        it "returns nil if record was not found" do
          subject.remove(person).should eq nil
        end

        it "removes the record" do
          subject.add person
          subject.remove person
          subject.get(person.class, person.id).should be_nil
        end

        it "returns the removed record" do
          subject.add person
          subject.remove(person).should eq person
        end

        it "removes a single table inheritance record" do
          subject.add friend
          subject.remove friend
          subject.get(friend.class, friend.id).should be_nil
        end
      end

      describe ".remove_by_id" do
        it "removes the record by it's class and id directly" do
          subject.add person
          subject.remove_by_id person.class, person.id
          subject.get(person.class, person.id).should be_nil
        end

        it "returns the removed record" do
          subject.add person
          subject.remove_by_id(person.class, person.id).should eq person
        end
      end
    end
  end


  describe "lifecycles on records" do
    include SetUpHbaseConnectionBeforeAll
    include SetTableNamesToTestTable

    let(:id) { "ID1" }

    describe "#find" do
      let(:person) do
        MassiveRecord::ORM::IdentityMap.without do
          Person.create!(id, :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true)
        end
      end

      context "when the record is not in the identity map" do
        it "asks do find for the record" do
          Person.should_receive(:do_find).and_return(nil)
          Person.find(id).should be_nil
        end

        it "adds the found record" do
          person

          MassiveRecord::ORM::IdentityMap.get(person.class, person.id).should be_nil
          Person.find(id)
          MassiveRecord::ORM::IdentityMap.get(person.class, person.id).should eq person
        end
      end

      context "when record is in identity map" do
        before { MassiveRecord::ORM::IdentityMap.add(person) }

        it "returns that record" do
          Person.table.should_not_receive(:find)
          Person.find(person.id).should eq person
        end
      end
    end

    describe "#save" do
      let(:person) { Person.create!(id, :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true) }

      context "a new record" do
        it "adds the record to the identity map after being created" do
          person
          Person.table.should_not_receive(:find)
          Person.find(person.id).should eq person
        end

        it "does not add the record if validation fails" do
          invalid_person = Person.create "ID2", :name => "Person2"
          Person.should_not be_exists invalid_person.id
        end
      end
    end
  end
end
