require 'spec_helper'
require 'orm/models/person'

describe "translation and naming" do
  before do
    I18n.backend = I18n::Backend::Simple.new
  end

  describe "of an attribute" do
    before do
      I18n.backend.store_translations 'en', :activemodel => {:attributes => {:person => {:name => "person's name"} } }
    end

    it "should look up an by a string" do
      Person.human_attribute_name("name").should == "person's name"
    end

    it "should look up an by a symbol" do
      Person.human_attribute_name(:name).should == "person's name"
    end
  end

  describe "of a model" do
    before do
      I18n.backend.store_translations 'en', :activemodel => {:models => {:person => 'A person object'}}
    end

    it "should return it's human name" do
      Person.model_name.human.should == "A person object"
    end
  end
end
