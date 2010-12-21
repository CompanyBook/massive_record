require 'spec_helper'
require 'orm/models/person'

describe "auto setting of ids" do
  include MockMassiveRecordConnection

  before do
    @person = Person.new :name => "thorbjorn", :age => 29
  end

  it "should return nil as default if no default_id is defined" do
    @person.id.should be_nil
  end

  it "should have id based on whatever default_id defines" do
    Person.class_eval do
      def default_id
        [name, age].join("-")
      end
    end

    @person.id.should == "thorbjorn-29"

    Person.class_eval do
      undef_method :default_id
    end
  end
end
