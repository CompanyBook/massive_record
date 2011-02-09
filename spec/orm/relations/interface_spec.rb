require 'spec_helper'
require 'orm/models/person'
require 'orm/models/person_with_timestamps'

describe MassiveRecord::ORM::Relations::Interface do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  describe "class methods" do
    subject { Person }

    describe "should include" do
      %w(references_one).each do |relation|
        it { should respond_to relation }
      end
    end
  end


  describe "references one" do
    describe "relation's meta data" do
      subject { Person.relations.detect { |relation| relation.name == "boss" } }

      it "should have the reference one meta data stored in relations" do
        Person.relations.detect { |relation| relation.name == "boss" }.should_not be_nil
      end

      it "should have type set to references_one" do
        subject.relation_type.should == "references_one"
      end

      it "should raise an error if the same relaton is called for twice" do
        lambda { Person.references_one :boss }.should raise_error MassiveRecord::ORM::RelationAlreadyDefined
      end
    end


    describe "instance" do
      subject { Person.new }
      let(:boss) { PersonWithTimestamps.new }

      it { should respond_to :boss }
      it { should respond_to :boss= }
      it { should respond_to :boss_id }
      it { should respond_to :boss_id= }


      describe "record getter and setter" do
        it "should return nil if foreign_key is nil" do
          subject.boss.should be_nil 
        end

        it "should return the proxy's target if boss is set" do
          subject.boss = boss
          subject.boss.should == boss
        end

        it "should set the foreign_key in owner when target is set" do
          subject.boss = boss
          subject.boss_id.should == boss.id
        end
      end
    end
  end
end
