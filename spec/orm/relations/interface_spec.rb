require 'spec_helper'
require 'orm/models/person'
require 'orm/models/person_with_timestamp'

describe MassiveRecord::ORM::Relations::Interface do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  describe "class methods" do
    subject { Person }

    describe "should include" do
      %w(references_one).each do |relation|
        it { should respond_to relation }
      end
    end

    it "should not share relations" do
      Person.relations.should_not == PersonWithTimestamp.relations
    end
  end


  describe "references one" do
    describe "relation's meta data" do
      subject { Person.relations.detect { |relation| relation.name == "boss" } }

      it "should have the reference one meta data stored in relations" do
        Person.relations.detect { |relation| relation.name == "boss" }.should_not be_nil
      end

      it "should have type set to references_one" do
        subject.relation_type.should == "references_one"
      end

      it "should raise an error if the same relaton is called for twice" do
        lambda { Person.references_one :boss }.should raise_error MassiveRecord::ORM::RelationAlreadyDefined
      end
    end


    describe "instance" do
      subject { Person.new }
      let(:boss) { PersonWithTimestamp.new }
      let(:proxy) { subject.send(:relation_proxy, "boss") }

      it { should respond_to :boss }
      it { should respond_to :boss= }
      it { should respond_to :boss_id }
      it { should respond_to :boss_id= }


      describe "record getter and setter" do
        it "should return nil if foreign_key is nil" do
          subject.boss.should be_nil 
        end

        it "should return the proxy's proxy_target if boss is set" do
          subject.boss = boss
          subject.boss.should == boss
        end

        it "should be able to reset the proxy" do
          proxy.should_receive(:load_proxy_target).and_return(true)
          proxy.should_receive(:reset) 
          subject.boss.reset
        end

        it "should be able to reload the proxy" do
          proxy.should_receive(:load_proxy_target).and_return(true)
          proxy.should_receive(:reload)
          subject.boss.reload
        end

        it "should set the foreign_key in proxy_owner when proxy_target is set" do
          subject.boss = boss
          subject.boss_id.should == boss.id
        end

        it "should load proxy_target object when read method is called" do
          PersonWithTimestamp.should_receive(:find).and_return(boss)
          subject.boss_id = boss.id
          subject.boss.should == boss
        end

        it "should not load proxy_target twice" do
          PersonWithTimestamp.should_receive(:find).once.and_return(boss)
          subject.boss_id = boss.id
          2.times { subject.boss }
        end
      end


      it "should be assignable in initializer" do
        person = Person.new :boss => boss
        person.boss.should == boss
      end
    end
  end


  describe "references one polymorphic" do
    describe "relation's meta data" do
      subject { TestClass.relations.detect { |relation| relation.name == "attachable" } }

      it "should have the reference one polymorphic meta data stored in relations" do
        TestClass.relations.detect { |relation| relation.name == "attachable" }.should_not be_nil
      end

      it "should have type set to correct type" do
        subject.relation_type.should == "references_one_polymorphic"
      end

      it "should raise an error if the same relaton is called for twice" do
        lambda { TestClass.references_one :attachable }.should raise_error MassiveRecord::ORM::RelationAlreadyDefined
      end
    end


    describe "instance" do
      subject { TestClass.new }
      let(:attachable) { Person.new }

      it { should respond_to :attachable }
      it { should respond_to :attachable= }
      it { should respond_to :attachable_id }
      it { should respond_to :attachable_id= }
      it { should respond_to :attachable_type }
      it { should respond_to :attachable_type= }


      describe "record getter and setter" do
        it "should return nil if foreign_key is nil" do
          subject.attachable.should be_nil 
        end

        it "should return the proxy's proxy_target if attachable is set" do
          subject.attachable = attachable
          subject.attachable.should == attachable
        end

        it "should set the foreign_key in proxy_owner when proxy_target is set" do
          subject.attachable = attachable
          subject.attachable_id.should == attachable.id
        end

        it "should set the type in proxy_owner when proxy_target is set" do
          subject.attachable = attachable
          subject.attachable_type.should == attachable.class.to_s
        end



        [Person, PersonWithTimestamp].each do |polymorphic_class|
          describe "polymorphic association to class #{polymorphic_class}" do
            let (:attachable) { polymorphic_class.new "ID1" }

            before do
              subject.attachable_id = attachable.id
              subject.attachable_type = polymorphic_class.to_s.underscore
            end

            it "should load proxy_target object when read method is called" do
              polymorphic_class.should_receive(:find).and_return(attachable)
              subject.attachable.should == attachable
            end

            it "should not load proxy_target twice" do
              polymorphic_class.should_receive(:find).once.and_return(attachable)
              2.times { subject.attachable }
            end
          end
        end
      end
    end
  end




  describe "references many" do
    describe "relation's meta data" do
      subject { Person.relations.detect { |relation| relation.name == "test_classes" } }

      it "should have the reference one meta data stored in relations" do
        Person.relations.detect { |relation| relation.name == "test_classes" }.should_not be_nil
      end

      it "should have type set to references_many" do
        subject.relation_type.should == "references_many"
      end

      it "should raise an error if the same relaton is called for twice" do
        lambda { Person.references_one :test_classes }.should raise_error MassiveRecord::ORM::RelationAlreadyDefined
      end
    end


    describe "instance" do
      subject { Person.new }
      let(:test_class) { TestClass.new }
      let(:proxy) { subject.send(:relation_proxy, "test_classes") }

      it { should respond_to :test_classes }
      it { should respond_to :test_classes= }
      it { should respond_to :test_class_ids }
      it { should respond_to :test_class_ids= }

      it "should have an array as foreign_key attribute" do
        subject.test_class_ids.should be_instance_of Array
      end

      it "should be assignable" do
        subject.test_classes = [test_class]
        subject.test_classes.should == [test_class]
      end

      it "should be assignable in initializer" do
        person = Person.new :test_classes => [test_class]
        person.test_classes.should == [test_class]
      end
    end
  end
end
