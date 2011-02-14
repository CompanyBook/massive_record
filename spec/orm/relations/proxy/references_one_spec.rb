require 'spec_helper'

class TestReferencesOneProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesOne; end

describe TestReferencesOneProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:owner) { Person.new }
  let(:target) { PersonWithTimestamps.new }
  let(:metadata) { subject.metadata }

  subject { owner.send(:relation_proxy, 'boss') }

  it_should_behave_like "relation proxy"

  it "should be possible to assign relation in new" do
    lambda { Person.new(:boss => PersonWithTimestamps.new) }.should_not raise_error
  end

  describe "#find_target" do
    it "should not try to find anything if foreign key is nil" do
      owner.boss_id = nil
      PersonWithTimestamps.should_not_receive(:find)
      subject.load_target.should be_nil
    end

    it "should try to find the target if foreign key is set" do
      owner.boss_id = "id"
      PersonWithTimestamps.should_receive(:find).with("id").and_return(target)
      subject.load_target.should == target
    end
  end

  describe "find with proc" do
    let(:person) { Person.new }

    before do
      subject.metadata.find_with = Proc.new { |target| Person.find("testing-123") }
      owner.boss_id = nil
    end

    it "should not call find_target" do
      should_not_receive :find_target
      subject.load_target
    end

    it "should load by given proc" do
      Person.should_receive(:find).with("testing-123").and_return(person)
      subject.load_target.should == person
    end
  end

  describe "setting target object" do
    it "should set the target's id as the foreign key in owner" do
      owner.boss = target
      owner.boss_id.should == target.id
    end

    it "should reset the targets foreign key if target is nil" do
      owner.boss = target
      owner.boss = nil
      owner.boss_id.should be_nil
    end

    it "should not set the target's ida as the foreign key if we are not persisting the foreign key" do
      owner.stub(:respond_to?).and_return(false)
      owner.boss = target
      owner.boss_id.should be_nil
    end

    it "should set the target's id as the foreign key even if we are not persisting it if the record responds to setter method" do
      owner.boss = target
      owner.boss_id.should == target.id
    end

    it "should raise an error if there is a type mismatch" do
      lambda { owner.boss = Person.new }.should raise_error MassiveRecord::ORM::RelationTypeMismatch
    end
  end


  describe "type checking of targets" do
    let(:metadata) { MassiveRecord::ORM::Relations::Metadata.new 'person' }
    let(:person) { Person.new }
    let(:person_with_timestamps) { PersonWithTimestamps.new }

    before do
      subject.metadata = metadata
    end

    it "should not raise error if metadata's class corresponds to given target" do
      lambda { subject.send :raise_if_type_mismatch, person }.should_not raise_error MassiveRecord::ORM::RelationTypeMismatch
    end

    it "should not raise error if metadata's class corresponds to given target" do
      lambda { subject.send :raise_if_type_mismatch, person_with_timestamps }.should raise_error MassiveRecord::ORM::RelationTypeMismatch
    end
  end
end
