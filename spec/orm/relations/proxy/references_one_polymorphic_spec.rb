require 'spec_helper'

class TestReferencesOnePolymorphicProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesOnePolymorphic; end

describe TestReferencesOnePolymorphicProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:owner) { TestClass.new }
  let(:target) { Person.new }
  let(:metadata) { subject.metadata }

  subject { owner.send(:relation_proxy, 'attachable') }

  before do
    owner.attachable_type = "person"
  end

  it_should_behave_like "relation proxy"
  it_should_behave_like "singular proxy"


  describe "#find_target" do
    it "should be able to find target if foreign_key and type is present in owner" do
      person = Person.new
      owner.attachable_id = "ID1"
      owner.attachable_type = "person"
      Person.should_receive(:find).and_return(person)
      owner.attachable.should == person
    end

    it "should not be able to find target if foreign_key is nil" do
      owner.attachable_id = nil
      owner.attachable_type = "person"
      Person.should_not_receive(:find)
      owner.attachable
    end

    it "should not be able to find target if type is nil" do
      owner.attachable_id = "ID1"
      owner.attachable_type = nil
      Person.should_not_receive(:find)
      owner.attachable
    end
  end


  describe "setting target object" do
    it "should set the target's id as the foreign key in owner" do
      owner.attachable = target
      owner.attachable_id.should == target.id
    end

    it "should set the target's type in owner" do
      owner.attachable_type = nil
      owner.attachable = target
      owner.attachable_type.should == target.class.to_s.underscore
    end

    it "should reset the targets foreign key if target is nil" do
      owner.attachable = target
      owner.attachable = nil
      owner.attachable_id.should be_nil
    end

    it "should reset the target's type in owner if target is nil" do
      owner.attachable = target
      owner.attachable = nil
      owner.attachable_type.should be_nil
    end

    it "should not set the target's id as the foreign key if we are not persisting the foreign key" do
      owner.stub(:respond_to?).and_return(false)
      owner.attachable = target
      owner.attachable_id.should be_nil
    end

    it "should not set the target's type if owner is not responding to type setter" do
      owner.attachable_type = nil
      owner.stub(:respond_to?).and_return(false)
      owner.attachable = target
      owner.attachable_type.should be_nil
    end

    it "should set the target's id as the foreign key even if we are not persisting it if the record responds to setter method" do
      owner.attachable = target
      owner.attachable_id.should == target.id
    end
  end
end
