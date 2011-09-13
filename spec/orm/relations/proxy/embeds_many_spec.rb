require 'spec_helper'

class TestEmbedsManyProxy < MassiveRecord::ORM::Relations::Proxy::EmbedsMany; end

describe TestEmbedsManyProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:proxy_owner) { Person.new "person-id-1", :name => "Test", :age => 29 }
  let(:proxy_target) { Address.new "address-1", :street => "Asker", :number => 1 }
  let(:proxy_target_2) { TeAddressew "address-2", :street => "Asker", :number => 2 }
  let(:proxy_target_3) { TestAddress "address-3", :street => "Asker", :number => 3 }
  let(:metadata) { subject.metadata }

  subject { proxy_owner.send(:relation_proxy, 'addresses') }

  it_should_behave_like "relation proxy"

  describe "#raw" do
    it "is a hash" do
      subject.raw.should be_instance_of Hash
    end

    it "keeps id and attributes for added records" do
      subject << proxy_target
      subject.raw[proxy_target.id].should eq proxy_target.attributes_to_row_values_hash
    end

    it "removes id and attributes for removed records" do
      subject << proxy_target
      subject.destroy(proxy_target)
      subject.raw.should be_empty
    end
  end
end
