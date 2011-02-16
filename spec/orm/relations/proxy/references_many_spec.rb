require 'spec_helper'

class TestReferencesManyProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesMany; end

describe TestReferencesManyProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:owner) { Person.new :id => "person-id-1", :name => "Test", :age => 29 }
  let(:target) { TestClass.new :id => "test-class-id-1" }
  let(:target_2) { TestClass.new :id => "test-class-id-2" }
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

    it "should always wrap the proc's result in an array" do
      TestClass.should_receive(:find).with("testing-123").and_return(test_class)
      subject.load_target.should == [test_class]
    end
  end


  describe "adding records to collection" do
    [:<<, :push, :concat].each do |add_method|
      describe "by ##{add_method}" do
        it "should include the target in the proxy" do
          subject.send(add_method, target)
          subject.target.should include target
        end

        it "should update array of foreign keys in owner" do
          owner.test_classes_ids.should be_empty
          subject.send(add_method, target)
          owner.test_classes_ids.should include(target.id)
        end

        it "should update array of foreign keys in owner" do
          owner.save!
          subject.send(add_method, target)
          owner.save! and owner.reload
          owner.test_classes_ids.should include(target.id)
        end

        it "should not update array of foreign keys in owner if it does not respond to it" do
          owner.should_receive(:respond_to?).and_return(false)
          subject.send(add_method, target)
          owner.test_classes_ids.should_not include(target.id)
        end

        it "should not do anything adding the same record twice" do
          2.times { subject.send(add_method, target) }
          subject.target.length.should == 1
          owner.test_classes_ids.length.should == 1
        end

        it "should be able to add two records at the same time" do
          subject.send add_method, [target, target_2]
          subject.target.should include target
          subject.target.should include target_2
        end

        it "should return proxy so calls can be chained" do
          subject.send(add_method, target).should == subject
        end

        it "should raise an error if there is a type mismatch" do
          lambda { subject.send add_method, Person.new }.should raise_error MassiveRecord::ORM::RelationTypeMismatch
        end
      end
    end
  end
end
