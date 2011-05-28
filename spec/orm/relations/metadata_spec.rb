require 'spec_helper'
require 'orm/models/person'

describe MassiveRecord::ORM::Relations::Metadata do
  subject { MassiveRecord::ORM::Relations::Metadata.new(nil) }

  %w(name foreign_key class_name relation_type find_with polymorphic records_starts_from).each do |attr|
    it { should respond_to attr }
    it { should respond_to attr+"=" }
  end


  it "should be setting values by initializer" do
    metadata = subject.class.new :car, :foreign_key => :my_car_id, :class_name => "Vehicle", :store_in => :info, :polymorphic => true, :records_starts_from => :records_starts_from
    metadata.name.should == "car"
    metadata.foreign_key.should == "my_car_id"
    metadata.class_name.should == "Vehicle"
    metadata.store_in.should == "info"
    metadata.records_starts_from.should == :records_starts_from
    metadata.should be_polymorphic
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

    it "should calculate correct class name if represents a collection" do
      subject.relation_type = "references_many"
      subject.name = "persons"
      subject.class_name.should == "Person"
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

    it "should return plural for if meta data is representing a many relation" do
      subject.relation_type = :references_many
      subject.name = :persons
      subject.foreign_key.should == "person_ids"
    end
  end

  describe "#foreign_key_setter" do
    it "should return whatever the foreign_key is pluss =" do
      subject.should_receive(:foreign_key).and_return("custom_key")
      subject.foreign_key_setter.should == "custom_key="
    end
  end



  describe "#store_in" do
    its(:store_in) { should be_nil }

    it "should be able to set column family to store foreign key in" do
      subject.store_in = :info
      subject.store_in.should == "info"
    end
  end

  it "should know its persisting foreign key if foreign key stored in has been set" do
    subject.store_in = :info
    should be_persisting_foreign_key
  end

  it "should not be storing the foreign key if records_starts_from is defined" do
    subject.store_in = :info
    subject.records_starts_from = :method_which_returns_a_starting_point
    should_not be_persisting_foreign_key
  end



  it "should compare two meta datas based on name" do
    other = MassiveRecord::ORM::Relations::Metadata.new(subject.name)
    other.should == subject
  end

  it "should have the same hash value for the same name" do
    subject.hash == subject.name.hash
  end



  describe "#new_relation_proxy" do
    let(:proxy_owner) { Person.new }
    let(:proxy) { subject.relation_type = "references_one" and subject.new_relation_proxy(proxy_owner) }

    it "should return a proxy where proxy_owner is assigned" do
      proxy.proxy_owner.should == proxy_owner
    end

    it "should return a proxy where metadata is assigned" do
      proxy.metadata.should == subject
    end

    it "should append _polymorphic to the proxy name if it is polymorphic" do
      subject.polymorphic = true
      subject.relation_type = "references_one"
      subject.relation_type.should == "references_one_polymorphic"
    end
  end


  describe "#polymorphic_type_column" do
    before do
      subject.polymorphic = true
    end

    it "should remove _id and add _type to foreign_key" do
      subject.should_receive(:foreign_key).and_return("foo_id")
      subject.polymorphic_type_column.should == "foo_type"
    end

    it "should simply add _type if foreign_key does not end on _id" do
      subject.should_receive(:foreign_key).and_return("foo_id_b")
      subject.polymorphic_type_column.should == "foo_id_b_type"
    end

    it "should return setter method" do
      subject.should_receive(:polymorphic_type_column).and_return("yey")
      subject.polymorphic_type_column_setter.should == "yey="
    end
  end


  describe "records_starts_from" do
    it "should not have any proc if records_starts_from is nil" do
      subject.find_with = "foo"
      subject.records_starts_from = nil
      subject.find_with.should be_nil
    end

    it "should buld a proc with records_starts_from set" do
      subject.records_starts_from = :friends_records_starts_from_id
      subject.find_with.should be_instance_of Proc
    end

    describe "proc" do
      let(:proxy_owner) { Person.new "person-1" }
      let(:find_with_proc) { subject.records_starts_from = :friends_records_starts_from_id; subject.find_with }

      before do
        subject.class_name = "Person"
      end

      it "should call proxy_target class with all, start with proxy_owner's start from id response" do
        Person.should_receive(:all).with(hash_including(:start => proxy_owner.friends_records_starts_from_id))
        find_with_proc.call(proxy_owner)
      end

      it "should be possible to send in options to the proc" do
        Person.should_receive(:all).with(hash_including(:limit => 10, :start => proxy_owner.friends_records_starts_from_id))
        find_with_proc.call(proxy_owner, {:limit => 10})
      end
    end
  end
end
