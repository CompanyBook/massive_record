require 'spec_helper'

class TestEmbeddedInProxy < MassiveRecord::ORM::Relations::Proxy::EmbeddedIn; end

describe TestEmbeddedInProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:proxy_owner) { Address.new "address-1", :street => "Asker", :number => 1 }
  let(:proxy_target) { Person.new "person-id-1", :name => "Test", :age => 29 }
  let(:proxy_target_2) { Person.new "person-id-2", :name => "Test", :age => 29 }
  
  let(:metadata) { subject.metadata }

  subject { proxy_owner.send(:relation_proxy, 'person') }


  it_should_behave_like "relation proxy"

  describe "#replace" do
    context "current target being blank" do
      it "adds itself to the targets embedded collection" do
        subject.replace(proxy_target)
        proxy_target.addresses.should include proxy_owner
      end
    end

    context "current target existing" do
      context "and target is the same as current" do
        it "just push self to target once" do
          proxy_target.should_receive(:addresses).twice.and_return([])
          2.times { subject.replace(proxy_target) }
          proxy_target.addresses.should include proxy_owner
        end
      end

      context "and new target is different than previos" do
        it "removes itself from old collection and inserts self into new" do
          proxy_target.save!
          proxy_target_2.save!

          subject.replace(proxy_target)
          subject.replace(proxy_target_2)

          proxy_target.addresses.should_not include proxy_owner
          proxy_target_2.addresses.should include proxy_owner
          proxy_owner.should_not be_destroyed
        end
      end
    end

    it "raises error if inverse of does not exist" do
      metadata.should_receive(:inverse_of).any_number_of_times.and_return("something_which_does_not_exist")
      expect { subject.replace(proxy_target) }.to raise_error MassiveRecord::ORM::RelationMissing
    end
  end

  describe "polymorphism" do
    let(:test_class) { TestClass.new }

    it "raises an error if invalid type is assigned" do
      expect { proxy_owner.person = test_class }.to raise_error MassiveRecord::ORM::RelationTypeMismatch
    end
  end
end

