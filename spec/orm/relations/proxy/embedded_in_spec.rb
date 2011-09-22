require 'spec_helper'

class TestEmbeddedInProxy < MassiveRecord::ORM::Relations::Proxy::EmbeddedIn; end

describe TestEmbeddedInProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:proxy_owner) { Address.new "address-1", :street => "Asker", :number => 1 }
  let(:proxy_target) { Person.new "person-id-1", :name => "Test", :age => 29 }
  
  let(:metadata) { subject.metadata }

  subject { proxy_owner.send(:relation_proxy, 'person') }


  it_should_behave_like "relation proxy"
end

