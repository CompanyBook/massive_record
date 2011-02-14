require 'spec_helper'
require 'orm/models/person'

describe MassiveRecord::ORM::Relations::Metadata do
  subject { MassiveRecord::ORM::Relations::Metadata.new(nil) }

  %w(name foreign_key class_name relation_type find_with).each do |attr|
    it { should respond_to attr }
    it { should respond_to attr+"=" }
  end


  it "should be setting values by initializer" do
    metadata = subject.class.new :car, :foreign_key => :my_car_id, :class_name => "Vehicle", :store_foreign_key_in => :info
    metadata.name.should == "car"
    metadata.foreign_key.should == "my_car_id"
    metadata.class_name.should == "Vehicle"
    metadata.store_foreign_key_in.should == "info"
  end

  it "should not be possible to set relation type through initializer" do
    metadata = subject.class.new :car, :relation_type => :foo
    metadata.relation_type.should be_nil
  end


  its(:name) { should be_nil }

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

    it "should try and calculate the foreign key from the name" do
      subject.class_name = "PersonWithSomething"
      subject.name = :person
      subject.foreign_key.should == "person_id"
    end
  end

  describe "#foreign_key_setter" do
    it "should return whatever the foreign_key is pluss =" do
      subject.should_receive(:foreign_key).and_return("custom_key")
      subject.foreign_key_setter.should == "custom_key="
    end
  end



  describe "#store_foreign_key_in" do
    its(:store_foreign_key_in) { should be_nil }

    it "should be able to set column family to store foreign key in" do
      subject.store_foreign_key_in = :info
      subject.store_foreign_key_in.should == "info"
    end
  end

  it "should know its persisting foreign key if foreign key stored in has been set" do
    subject.store_foreign_key_in = :info
    should be_persisting_foreign_key
  end



  it "should compare two meta datas based on name" do
    other = MassiveRecord::ORM::Relations::Metadata.new(subject.name)
    other.should == subject
  end

  it "should have the same hash value for the same name" do
    subject.hash == subject.name.hash
  end



  describe "#new_relation_proxy" do
    let(:owner) { Person.new }
    let(:proxy) { subject.relation_type = "references_one" and subject.new_relation_proxy(owner) }

    it "should return a proxy where owner is assigned" do
      proxy.owner.should == owner
    end

    it "should return a proxy where metadata is assigned" do
      proxy.metadata.should == subject
    end
  end
end
