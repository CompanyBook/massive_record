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
    its(:dictionary) { should eq Hash.new }
    its(:points) { should eq 1 }
    its(:status) { should eq false }
    its(:positive_as_default) { should eq true }
    its(:phone_numbers) { should eq [] }
  end

  context "persisted record" do
    before do
      subject.dictionary = nil
      subject.points = nil
      subject.status = nil
      subject.positive_as_default = false
      subject.phone_numbers = nil
      subject.save!
      subject.reload
    end

    its(:dictionary) { should be_nil }
    its(:points) { should be_nil }
    its(:status) { should be_nil }
    its(:positive_as_default) { should be_false }
    its(:phone_numbers) { should eq [] }
  end
end
