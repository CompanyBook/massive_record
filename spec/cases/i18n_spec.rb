require 'spec_helper'
require 'models/person'

describe "translation" do
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
end
