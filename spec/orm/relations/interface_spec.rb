require 'spec_helper'
require 'orm/models/person'

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
      subject { Person }

      it "should have the reference one meta data stored in relations" do
        subject.relations.detect { |relation| relation.name == "boss" }.should_not be_nil
      end
    end


    describe "instance" do
      subject { Person.new }

      it { should respond_to :boss }
      it { should respond_to :boss= }
      it { should respond_to :boss_id }
      it { should respond_to :boss_id= }
    end
  end
end
