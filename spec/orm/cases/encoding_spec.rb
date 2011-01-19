# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'orm/models/person'

describe "encoding" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  it "should be able to store UTF-8 encoded strings" do
    name = "Thorbjørn"
    person = Person.create! :id => "new_id", :name => name, :age => "22"
    person_from_db = Person.find(person.id)
    person_from_db.should == person
    person_from_db.name.should == name
  end
end
