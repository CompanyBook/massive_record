require 'spec_helper'

class TestEmbeddedInPolymorphicProxy < MassiveRecord::ORM::Relations::Proxy::EmbeddedInPolymorphic; end

describe TestEmbeddedInPolymorphicProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:proxy_owner) { Address.new "address-1", :street => "Asker", :number => 1 }
  let(:proxy_target) { TestClass.new "test-id-1" }
  
  let(:metadata) { subject.metadata }

  subject { proxy_owner.send(:relation_proxy, 'addressable') }


  describe "generic behaviour" do
    before do 
      # Little hack just to make one generic relation proxy test pass..
      metadata.stub(:proxy_target_class).and_return TestClass
    end

    it_should_behave_like "relation proxy"
  end



  describe "polymorphism" do
    let(:person) { Person.new "person-id-1", :name => "Test", :age => 29 }

    it "allows for polymorphism if configured for it" do
      expect { proxy_owner.adressable = person }.not_to raise_error MassiveRecord::ORM::RelationTypeMismatch
    end
  end
end


