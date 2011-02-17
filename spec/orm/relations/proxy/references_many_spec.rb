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
    describe "with foreig keys stored in owner" do
      it "should not try to find target if foreign_keys is blank" do
        owner.test_class_ids.clear
        TestClass.should_not_receive(:find)
        subject.load_target.should be_empty
      end

      it "should try to load target if foreign_keys has any keys" do
        owner.test_class_ids << target.id
        TestClass.should_receive(:find).with([target.id], anything).and_return([target])
        subject.load_target.should == [target]
      end

      it "should not die when loading foreign keys which does not exist in target table" do
        owner.save!
        owner.test_classes << target
        owner.test_classes.reset
        owner.test_class_ids << "does_not_exists"
        owner.test_classes.reload
        owner.test_classes.length.should == 1
      end
    end

    describe "with start from" do
      let(:target) { Person.new :id => owner.id+"-friend-1", :name => "T", :age => 2 }
      let(:target_2) { Person.new :id => owner.id+"-friend-2", :name => "H", :age => 9 }
      let(:not_target) { Person.new :id => "foo"+"-friend-2", :name => "H", :age => 1 }
      let(:metadata) { subject.metadata }

      subject { owner.send(:relation_proxy, 'friends') }

      before do
        target.save!
        target_2.save!
        not_target.save!
      end

      it "should not try to find target if start from method is blank" do
        owner.should_receive(:friends_records_starts_from_id).and_return(nil)
        Person.should_not_receive(:all)
        subject.load_target.should be_empty
      end

      it "should find all friends when loading" do
        friends = subject.load_target
        friends.length.should == 2
        friends.should include(target)
        friends.should include(target_2)
        friends.should_not include(not_target)
      end
    end
  end

  describe "find with proc" do
    let(:test_class) { TestClass.new }

    before do
      subject.metadata.find_with = Proc.new { |target| TestClass.find("testing-123") }
    end

    after do
      subject.metadata.find_with = nil
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

    it "should be empty if the proc return nil" do
      TestClass.should_receive(:find).with("testing-123").and_return(nil)
      subject.load_target.should be_empty
    end
  end


  describe "adding records to collection" do
    [:<<, :push, :concat].each do |add_method|
      describe "by ##{add_method}" do
        it "should include the target in the proxy" do
          subject.send(add_method, target)
          subject.target.should include target
        end

        it "should not add invalid objects to collection" do
          target.should_receive(:valid?).and_return false
          subject.send(add_method, target).should be_false
          subject.target.should_not include target
        end

        it "should update array of foreign keys in owner" do
          owner.test_class_ids.should be_empty
          subject.send(add_method, target)
          owner.test_class_ids.should include(target.id)
        end

        it "should update array of foreign keys in owner" do
          owner.save!
          subject.send(add_method, target)
          owner.save! and owner.reload
          owner.test_class_ids.should include(target.id)
        end

        it "should not update array of foreign keys in owner if it does not respond to it" do
          owner.should_receive(:respond_to?).and_return(false)
          subject.send(add_method, target)
          owner.test_class_ids.should_not include(target.id)
        end

        it "should not do anything adding the same record twice" do
          2.times { subject.send(add_method, target) }
          subject.target.length.should == 1
          owner.test_class_ids.length.should == 1
        end

        it "should be able to add two records at the same time" do
          subject.send add_method, [target, target_2]
          subject.target.should include target
          subject.target.should include target_2
        end

        it "should return proxy so calls can be chained" do
          subject.send(add_method, target).object_id.should == subject.object_id
        end

        it "should raise an error if there is a type mismatch" do
          lambda { subject.send add_method, Person.new(:name => "Foo", :age => 2) }.should raise_error MassiveRecord::ORM::RelationTypeMismatch
        end

        it "should not save the pushed target if owner is not persisted" do
          owner.should_receive(:persisted?).and_return false
          target.should_not_receive(:save)
          subject.send(add_method, target)
        end

        it "should not save the owner object if it has not been persisted before" do
          owner.should_receive(:persisted?).and_return false
          owner.should_not_receive(:save)
          subject.send(add_method, target)
        end

        it "should save the pushed target if owner is persisted" do
          owner.save!
          target.should_receive(:save).and_return(true)
          subject.send(add_method, target)
        end

        it "should not save anything if one record is invalid" do
          owner.save!

          target.should_receive(:valid?).and_return(true)
          target_2.should_receive(:valid?).and_return(false)
          
          target.should_not_receive(:save)
          target_2.should_not_receive(:save)
          owner.should_not_receive(:save)

          subject.send(add_method, [target, target_2]).should be_false
        end
      end
    end
  end

  describe "removing records from the collection" do
    [:destroy, :delete].each do |delete_method|
      describe "with ##{delete_method}" do
        before do
          subject << target
        end

        it "should not be in proxy after being removed" do
          subject.send(delete_method, target)
          subject.target.should_not include target
        end

        it "should remove the destroyed records id from owner foreign keys" do
          subject.send(delete_method, target)
          owner.test_class_ids.should_not include(target.id)
        end

        it "should not remove foreign keys in owner if it does not respond to it" do
          owner.should_receive(:respond_to?).and_return false
          subject.send(delete_method, target)
          owner.test_class_ids.should include(target.id)
        end

        it "should ask the record to #{delete_method} self" do
          target.should_receive(delete_method)
          subject.send(delete_method, target)
        end

        it "should not save the owner if it has not been persisted" do
          owner.should_receive(:persisted?).and_return(false)
          owner.should_not_receive(:save)
          subject.send(delete_method, target)
        end

        it "should save the owner if it has been persisted" do
          owner.save!
          owner.should_receive(:save)
          subject.send(delete_method, target)
        end
      end
    end



    describe "with destroy_all" do
      before do
        owner.save!
        subject << target << target_2
      end

      it "should not include any records after destroying all" do
        subject.destroy_all
        subject.target.should be_empty
      end

      it "should remove all foreign keys in owner" do
        subject.destroy_all
        owner.test_class_ids.should be_empty
      end

      it "should call reset after all destroyed" do
        subject.should_receive(:reset)
        subject.destroy_all
      end

      it "should be loaded after all being destroyed" do
        subject.destroy_all
        should be_loaded
      end
    end
  end
end
