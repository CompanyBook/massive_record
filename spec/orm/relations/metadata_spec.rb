require 'spec_helper'
require 'orm/models/person'

describe MassiveRecord::ORM::Relations::Metadata do
  subject { MassiveRecord::ORM::Relations::Metadata.new }

  %w(name foreign_key class_name).each do |attr|
    it { should respond_to attr }
    it { should respond_to attr+"=" }
  end


  describe "#class_name" do
    it "should return whatever it's being set to" do
      subject.class_name = "Person"
      subject.class_name.should == "Person"
    end

    it "should return class name as a string" do
      subject.class_name = Person
      subject.class_name.should == "Person"
    end

    it "should calculate it from name" do
      subject.name = :employee
      subject.class_name.should == "Employee"
    end
  end




  describe "#foreign_key" do
    it "should return whatever it's being set to" do
      subject.foreign_key = "person_id"
      subject.foreign_key.should == "person_id"
    end

    it "should try and calculate the foreign key from the class name" do
      pending
    end
  end
end
