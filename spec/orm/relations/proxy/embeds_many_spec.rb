require 'spec_helper'

class TestEmbedsManyProxy < MassiveRecord::ORM::Relations::Proxy::EmbedsMany; end

describe TestEmbedsManyProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:proxy_owner) { Person.new :id => "person-id-1", :name => "Test", :age => 29 }
  let(:proxy_target) { Address.new :id => "address-1" }
  let(:proxy_target_2) { TeAddressew :id => "address-2" }
  let(:proxy_target_3) { TestAddress :id => "address-3" }
  let(:metadata) { subject.metadata }

  subject { proxy_owner.send(:relation_proxy, 'addresses') }

  it_should_behave_like "relation proxy"
end
