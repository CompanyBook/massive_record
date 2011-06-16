require 'spec_helper'

describe "default values" do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  subject do
    Person.new("id", {
      :name => "Thorbjorn",
      :age => 22,
      :points => 1
    })
  end

  context "new record" do
    its(:addresses) { should eq Hash.new }
    its(:points) { should eq 1 }
    its(:status) { should eq false }
    its(:phone_numbers) { should eq [] }
  end

  context "persisted record" do
    before do
      subject.addresses = nil
      subject.points = nil
      subject.status = nil
      subject.phone_numbers = nil
      subject.save!
      subject.reload
    end

    its(:addresses) { should be_nil }
    its(:points) { should be_nil }
    its(:status) { should be_nil }
    its(:phone_numbers) { should eq [] }
  end
end
