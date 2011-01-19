# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'orm/models/person'

describe "encoding" do

  describe "with ORM" do
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

  describe "without ORM" do
    include CreatePersonBeforeEach

    it "should be able to store UTF-8 encoded strings" do
      id = "ID-encoding-test"
      name = "Thorbjørn"

      @row = MassiveRecord::Wrapper::Row.new
      @row.table = @table
      @row.id = id
      @row.values = {:info => {:name => name, :email => "john@base.com", :age => "20"}}
      @row.save

      @row_from_db = @table.find(id) 
      @row_from_db.values["info:name"].should == name
    end
  end
end
