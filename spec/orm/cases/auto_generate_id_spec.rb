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

    Person.class_eval { undef_method :default_id }
  end

  it "should have id based on whatever default_id defines, even if it is private method" do
    Person.class_eval do
      private
      def default_id
        [name, age].join("-")
      end
    end

    @person.id.should == "thorbjorn-29"

    Person.class_eval { undef_method :default_id }
  end

  describe "#next_id" do
    it "should ask IdFactory for a next id for self" do
      Person.class_eval do
        def default_id
          next_id
        end
      end

      MassiveRecord::ORM::IdFactory.should_receive(:next_for).with(Person).and_return(1)
      @person.id.should == "1"

      Person.class_eval { undef_method :default_id }
    end
  end
end
