require 'spec_helper'

class TestReferencesOneProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesOne; end

describe TestReferencesOneProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  it_should_behave_like MassiveRecord::ORM::Relations::Proxy

  let(:owner) { Person.new }
  let(:target) { PersonWithTimestamps.new }
  let(:metadata) { Person.relations.find { |r| r.name == 'boss' } }

  before do
    subject.metadata = metadata
    subject.owner = owner
  end

  describe "#find_target" do
    it "should not try to find anything if foreign key is nil" do
      owner.boss_id = nil
      subject.load_target.should be_nil
    end

    it "should try to find the target if foreign key is set" do
      owner.boss_id = "id"
      PersonWithTimestamps.should_receive(:find).with("id").and_return(target)
      subject.load_target.should == target
    end
  end
end
