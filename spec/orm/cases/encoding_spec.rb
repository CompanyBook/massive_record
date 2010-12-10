# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'orm/models/person'

describe "encoding" do
  include SetUpHbaseConnectionBeforeAll
  include SetPersonsTableNameToTestTable

  it "should be able to store UTF-8 encoded strings" do
    pending "!!!!!!!!!!!! ---------------------------- >>>> Vincent: I think you have encountered something similar before? Want to take a look at this? :-)"

    person = Person.create! :id => "new_id", :name => "Thorbjørn", :age => "22"
    person_from_db = Person.find(person.id)
    person_from_db.should == person
    person_from_db.name.should == "Thorbjørn"
  end
end
