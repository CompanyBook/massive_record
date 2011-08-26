require 'spec_helper'
require 'orm/models/friend'
require 'orm/models/best_friend'

describe MassiveRecord::ORM::IdentityMap do
  before { MassiveRecord::ORM::IdentityMap.clear }

  describe "class methods" do
    subject { described_class }

    describe "confirguration" do
      describe ".enabled" do
        context "when disabled" do
          its(:enabled) { should be_false }
          its(:enabled?) { should be_false }
        end

        context "when enabled" do
          before { MassiveRecord::ORM::IdentityMap.enabled = true }
          its(:enabled) { should be_true }
          its(:enabled?) { should be_true }
        end
      end
    end

    describe "persistence" do
      let(:person) { Person.new "id1" }
      let(:friend) { Friend.new "id2" }

      describe ".repository" do
        its(:repository) { should eq Hash.new }

        it "has values as a hash by default for any key" do
          subject.repository['some_class'].should eq Hash.new
        end
      end

      describe ".clear" do
        it "removes all values from repository" do
          subject.repository['some_class']['an_id'] = Object.new
          subject.clear
          subject.repository.should be_empty
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
        end
      end

      describe ".add" do
        it "persists the record" do
          subject.add person
          subject.repository[subject.send(:record_class_to_repository_key, person)][person.id].should eq person
        end
      end

      describe ".remove" do
        it "removes the record" do
          subject.add person
          subject.remove person
          subject.get(person.class, person.id).should be_nil
        end
      end
    end
  end
end
