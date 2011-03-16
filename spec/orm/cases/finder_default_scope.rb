require 'spec_helper'
require 'orm/models/person'

describe "Default scope in" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  describe Person do
    let(:subject) { Person.new :id => "ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true }

    before do
      subject.save!

      Person.class_eval do
        default_scope select(:info)
      end
    end

    after do
      Person.class_eval do
        default_scope nil
      end
    end



    it "should only load column family info as a default" do
      Person.first.points.should be_nil # its in :base
    end

    it "should be possible to bypass default scope by unscoped" do
      Person.unscoped.first.points.should == 111
    end

    it "should be possible to set default_scope with a hash" do
      Person.class_eval do
        default_scope :seleft => :base
      end

      person = Person.first
      person.points.should == 111
      person.name.should be_nil
    end
  end
end
