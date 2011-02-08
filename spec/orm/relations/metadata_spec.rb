require 'spec_helper'
require 'orm/models/person'

describe MassiveRecord::ORM::Relations::Metadata do
  subject { MassiveRecord::ORM::Relations::Metadata.new(nil) }

  %w(name foreign_key class_name).each do |attr|
    it { should respond_to attr }
    it { should respond_to attr+"=" }
  end


  it "should be setting values by initializer" do
    metadata = subject.class.new :car, :foreign_key => :my_car_id, :class_name => "Vehicle"
    metadata.name.should == "car"
    metadata.foreign_key.should == "my_car_id"
    metadata.class_name.should == "Vehicle"
  end


  it "should return name as string" do
    subject.name = :foo
    subject.name.should == "foo"
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

    it "should not need to calculate twice" do
      subject.should_receive(:calculate_class_name).once.and_return("foo")
      2.times { subject.class_name }
    end
  end




  describe "#foreign_key" do
    it "should return whatever it's being set to" do
      subject.foreign_key = "person_id"
      subject.foreign_key.should == "person_id"
    end

    it "should return foreign key as string" do
      subject.foreign_key = :person_id
      subject.foreign_key.should == "person_id"
    end

    it "should try and calculate the foreign key from the class name" do
      subject.name = Person
      subject.foreign_key.should == "person_id"
    end

    it "should not need to calculate twice" do
      subject.should_receive(:calculate_foreign_key).once.and_return("foo")
      2.times { subject.foreign_key }
    end
  end



  it "should compare two meta datas based on name" do
    other = MassiveRecord::ORM::Relations::Metadata.new(subject.name)
    other.should == subject
  end

  it "should have the same hash value for the same name" do
    subject.hash == subject.name.hash
  end
end
