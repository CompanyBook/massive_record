require 'spec_helper'

class TestReferencesOnePolymorphicProxy < MassiveRecord::ORM::Relations::Proxy::ReferencesOnePolymorphic; end

describe TestReferencesOnePolymorphicProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:owner) { TestClass.new }
  let(:target) { Person.new }
  let(:metadata) { subject.metadata }

  subject { owner.send(:relation_proxy, 'attachable') }

  it_should_behave_like "relation proxy"
end
