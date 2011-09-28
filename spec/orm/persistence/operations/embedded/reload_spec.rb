
require 'spec_helper'

describe MassiveRecord::ORM::Persistence::Operations::Embedded::Insert do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:record) { Address.new("addresss-id", :street => "Asker", :number => 5) }
  let(:person) { Person.new "person-id", :name => "Thorbjorn", :age => "22" }
  let(:options) { {:this => 'hash', :has => 'options'} }
  
  subject { described_class.new(record, options) }

  describe "generic behaviour" do
    before { record.person = person }
    it_should_behave_like "a persistence embedded operation class"
  end


  describe "#execute" do
  end
end
