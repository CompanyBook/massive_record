require 'spec_helper'

class TestReferencesManyProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesMany; end

describe TestReferencesManyProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:owner) { Person.new }
  let(:target) { TestClass.new :id => "test-class-id-1" }
  let(:metadata) { subject.metadata }

  subject { owner.send(:relation_proxy, 'test_classes') }

  it_should_behave_like "relation proxy"

  

  describe "#find_target" do
    it "should not try to find target if foreign_keys is blank" do
      owner.test_classes_ids.clear
      TestClass.should_not_receive(:find)
      subject.load_target.should be_empty
    end

    it "should try to load target if foreign_keys has any keys" do
      owner.test_classes_ids << target.id
      TestClass.should_receive(:find).with([target.id]).and_return([target])
      subject.load_target.should == [target]
    end
  end

  describe "find with proc" do
    let(:test_class) { TestClass.new }

    before do
      subject.metadata.find_with = Proc.new { |target| TestClass.find("testing-123") }
      owner.boss_id = nil
    end

    it "should not call find_target" do
      should_not_receive :find_target
      subject.load_target
    end

    it "should load by given proc" do
      TestClass.should_receive(:find).with("testing-123").and_return([test_class])
      subject.load_target.should == [test_class]
    end
  end
end
