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
        it "raises error if no ids are given" do
          expect { subject.get(person.class) }.to raise_error ArgumentError
        end

        context "when it does not has the record" do
          it "returns nil" do
            subject.get(person.class, person.id).should be_nil
          end

          it "returns empty array if asked for multiple records" do
            subject.get(person.class, 1, 2).should eq []
          end
        end

        context "when it has the record" do
          it "returns the record" do
            subject.add person
            subject.get(person.class, person.id).should eq person
          end

          describe "single table inheritahce" do
            before { subject.add friend }

            it "returns the record when looked up by it's class" do
              subject.get(friend.class, friend.id).should eq friend
            end

            it "returns the record when looked up by it's parent class" do
              subject.get(person.class, friend.id).should eq friend
            end

            it "raises an error when you request a parent class via a descendant class" do
              subject.add person
              expect {
                subject.get(friend.class, person.id)
              }.to raise_error MassiveRecord::ORM::IdentityMap::RecordIsSuperClassOfQueriedClass
            end
          end

          describe "get multiple" do
            it "returns multiple records when asked for multiple ids" do
              subject.add person
              subject.add friend
              subject.get(person.class, person.id, friend.id).should include person, friend
            end

            it "returns multiple records when asked for multiple ids as an array" do
              subject.add person
              subject.add friend
              subject.get(person.class, [person.id, friend.id]).should include person, friend
            end

            it "returns array when get got an array, even with only one id" do
              subject.add friend
              subject.get(person.class, [friend.id]).should eq [friend]
            end

            it "returns nothing for unkown ids" do
              subject.add person
              subject.add friend
              subject.get(person.class, person.id, friend.id, "unkown").length.should eq 2
            end
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
    let(:id_2) { "ID2" }
    let(:person) { Person.create!(id, :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true) }
    let(:friend) { Friend.create!(id_2, :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true) }

    describe "#find" do
      describe "one" do
        context "when the record is not in the identity map" do
          it "asks do find for the record" do
            Person.should_receive(:do_find).and_return(nil)
            Person.find(id).should be_nil
          end

          it "adds the found record" do
            MassiveRecord::ORM::IdentityMap.without { person }

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

          it "returns record from database when select option is used" do
            MassiveRecord::ORM::IdentityMap.should_not_receive(:get)
            Person.select(:info).find(person.id).should eq person
          end

          it "returns record from identity map when you ask for a sub class by its parent class" do
            MassiveRecord::ORM::IdentityMap.add(friend)
            Person.table.should_not_receive(:find)
            Person.find(friend.id).should eq friend
          end

          it "returns nil when you ask for a parent class" do
            Friend.table.should_not_receive(:find)
            Friend.find(person.id).should be_nil
          end
        end
      end

      describe "many" do
        it "returns records from database when select option is used" do
          MassiveRecord::ORM::IdentityMap.should_not_receive(:get)
          Person.select(:info).find([person.id, friend.id]).should include person, friend
        end

        context "when no records are in the identity map" do
          it "asks find for the two records" do
            Person.should_receive(:do_find).with([id, id_2], anything).and_return []
            Person.find([id, id_2]).should eq []
          end

          it "adds the found recods" do
            MassiveRecord::ORM::IdentityMap.without { person; friend }
            MassiveRecord::ORM::IdentityMap.get(person.class, person.id, friend.id).should be_empty

            Person.find([id, id_2])
            MassiveRecord::ORM::IdentityMap.get(person.class, person.id, friend.id).should include person, friend
          end
        end

        context "when all records are in the identity map" do
          before do
            MassiveRecord::ORM::IdentityMap.add(person)
            MassiveRecord::ORM::IdentityMap.add(friend)
          end

          it "returns records from identity map" do
            Person.table.should_not_receive(:find)
            Person.find([person.id, friend.id])
          end

          it "returns only records equal to or descendants of queried class" do
            Friend.find([person.id, friend.id]).should eq [friend]
          end
        end

        context "when some records are in the identity map" do
          before do
            MassiveRecord::ORM::IdentityMap.add(person)
            MassiveRecord::ORM::IdentityMap.without { friend }
          end

          it "returns records from identity map" do
            Person.should_receive(:query_hbase).with([friend.id], anything).and_return [friend]
            Person.find([person.id, friend.id])
          end
        end
      end
    end

    describe "#save" do
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

    describe "#destroy" do
      it "removes the record from identiy map" do
        person.destroy
        Person.should_not be_exists person.id
      end
    end

    describe "#destroy_all" do
      it "removes the record from identiy map" do
        person
        Person.destroy_all
        Person.should_not be_exists person.id
      end
    end

    describe "#delete" do
      it "removes the record from identiy map" do
        person.delete
        Person.should_not be_exists person.id
      end
    end

    describe "#reload" do
      it "reloads it's attributes" do
        what_it_was = person.name
        person.name = person.name.reverse

        person.reload
        person.name.should eq what_it_was
      end
    end
  end
end
