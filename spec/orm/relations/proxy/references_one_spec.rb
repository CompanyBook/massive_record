require 'spec_helper'

class TestReferencesOneProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesOne; end

describe TestReferencesOneProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  it_should_behave_like "relation proxy"

  let(:owner) { Person.new }
  subject { owner.send(:relation_proxy, 'boss') }
  let(:target) { PersonWithTimestamps.new }
  let(:metadata) { subject.metadata }


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

  describe "setting target object" do
    it "should set the target's id as the foreign key in owner" do
      owner.boss = target
      owner.boss_id.should == target.id
    end

    it "should not set the target's as the foreign key if we are not persisting the foreign key" do
      metadata.should_receive(:persisting_foreign_key?).and_return(false)
      owner.boss = target
      owner.boss_id.should be_nil
    end
  end
end
