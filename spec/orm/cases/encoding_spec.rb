# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'orm/models/person'

describe "encoding" do
  include SetUpHbaseConnectionBeforeAll
  include SetPersonsTableNameToTestTable

  it "should be able to store UTF-8 encoded strings" do
    pending "!!!!!!!!!!!! ---------------------------- >>>> Vincent: I think you have encountered something similar before? Want to take a look at this? :-)"
    
    # TODO  This needs to be fixed. I kinda "fixed" it by forcing the encoding to
    #       ASCII-8BIT on the Wrapper::Cell's serialize_value and deserialize_value, but
    #       I don't feel confident that it completely solves it, so I'll leave it for now.
    #       Vincent has asked about it on a mailing list, so we'll wait on some answers.

    person = Person.create! :id => "new_id", :name => "Thorbjørn", :age => "22"
    person_from_db = Person.find(person.id)
    person_from_db.should == person
    person_from_db.name.should == "Thorbjørn"
  end
end
