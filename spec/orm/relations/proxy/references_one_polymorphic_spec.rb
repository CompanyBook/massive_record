require 'spec_helper'

class TestReferencesOnePolymorphicProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesOnePolymorphic; end

describe TestReferencesOnePolymorphicProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:proxy_owner) { TestClass.new }
  let(:proxy_target) { Person.new }
  let(:metadata) { subject.metadata }

  subject { proxy_owner.send(:relation_proxy, 'attachable') }

  describe "normal proxy behaviour" do
    before do
      proxy_owner.attachable_type = "person"
    end

    it_should_behave_like "relation proxy"
    it_should_behave_like "singular proxy"
  end


  describe "#find_proxy_target" do
    it "should be able to find proxy_target if foreign_key and type is present in proxy_owner" do
      person = Person.new
      proxy_owner.attachable_id = "ID1"
      proxy_owner.attachable_type = "person"
      Person.should_receive(:find).and_return(person)
      proxy_owner.attachable.should == person
    end

    it "should not be able to find proxy_target if foreign_key is nil" do
      proxy_owner.attachable_id = nil
      proxy_owner.attachable_type = "person"
      Person.should_not_receive(:find)
      proxy_owner.attachable
    end

    it "should not be able to find proxy_target if type is nil" do
      proxy_owner.attachable_id = "ID1"
      proxy_owner.attachable_type = nil
      Person.should_not_receive(:find)
      proxy_owner.attachable
    end
  end


  describe "setting proxy_target object" do
    it "should set the proxy_target's id as the foreign key in proxy_owner" do
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable_id.should == proxy_target.id
    end

    it "should set the proxy_target's type in proxy_owner" do
      proxy_owner.attachable_type = nil
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable_type.should == proxy_target.class.to_s
    end

    it "should reset the proxy_targets foreign key if proxy_target is nil" do
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable = nil
      proxy_owner.attachable_id.should be_nil
    end

    it "should reset the proxy_target's type in proxy_owner if proxy_target is nil" do
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable = nil
      proxy_owner.attachable_type.should be_nil
    end

    it "should not set the proxy_target's id as the foreign key if we are not persisting the foreign key" do
      proxy_owner.stub(:respond_to?).and_return(false)
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable_id.should be_nil
    end

    it "should not set the proxy_target's type if proxy_owner is not responding to type setter" do
      proxy_owner.attachable_type = nil
      proxy_owner.stub(:respond_to?).and_return(false)
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable_type.should be_nil
    end

    it "should not set the proxy_target's id as the foreign key if the owner has been destroyed" do
      proxy_owner.should_receive(:destroyed?).and_return true
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable_id.should be_nil
    end

    it "should not set the proxy_target's type as the foreign key if the owner has been destroyed" do
      proxy_owner.should_receive(:destroyed?).and_return true
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable_type.should be_nil
    end



    it "should set the proxy_target's id as the foreign key even if we are not persisting it if the record responds to setter method" do
      proxy_owner.attachable = proxy_target
      proxy_owner.attachable_id.should == proxy_target.id
    end
  end

  it "resets when the proxy owner is asked to reload" do
    subject.loaded!
    proxy_owner.reload
    should_not be_loaded
  end
end
