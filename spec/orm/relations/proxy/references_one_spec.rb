require 'spec_helper'

class TestReferencesOneProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesOne; end

describe TestReferencesOneProxy do
  it_should_behave_like MassiveRecord::ORM::Relations::Proxy

  let(:owner) { Person.new }
  let(:target) { PersonWithTimestamps.new }

  before do
    subject.owner = owner
  end

  describe "#find_target" do
    it "should not try to find anything if foreign key is nil" do
      owner.boss_id = nil
      subject.send(:find_target).should be_nil
    end
  end
end
