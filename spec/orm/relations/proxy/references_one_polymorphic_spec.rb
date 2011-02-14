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
end
