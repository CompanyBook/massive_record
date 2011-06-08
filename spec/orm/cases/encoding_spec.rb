# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'orm/models/person'

describe "encoding" do

  describe "with ORM" do
    include SetUpHbaseConnectionBeforeAll
    include SetTableNamesToTestTable

    before do
      @person = Person.create! "new_id", :name => "Thorbjørn", :age => "22"
      @person_from_db = Person.find(@person.id)
    end

    it "should be able to store UTF-8 encoded strings" do
      @person_from_db.should == @person
      @person_from_db.name.should == "Thorbjørn"
    end

    it "should return string as UTF-8 encoded strings" do
      @person_from_db.name.encoding.should == Encoding::UTF_8
    end
  end

  describe "without ORM" do
    include CreatePersonBeforeEach

    before do
      @id = "ID-encoding-test"

      @row = MassiveRecord::Wrapper::Row.new
      @row.table = @table
      @row.id = @id
      @row.values = {:info => {:name => "Thorbjørn", :email => "john@base.com", :age => "20"}}
      @row.save

      @row_from_db = @table.find(@id) 
    end

    it "should be able to store UTF-8 encoded strings" do
      @row_from_db.values["info:name"].force_encoding(Encoding::UTF_8).should == "Thorbjørn"
    end

    it "should return string as UTF-8 encoded strings" do
      @row_from_db.values["info:name"].encoding.should == Encoding::BINARY
    end
  end
end
