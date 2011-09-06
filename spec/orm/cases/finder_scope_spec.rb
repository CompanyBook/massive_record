require 'spec_helper'
require 'orm/models/person'

describe MassiveRecord::ORM::Finders::Scope do
  let(:subject) { MassiveRecord::ORM::Finders::Scope.new(nil) }

  MassiveRecord::ORM::Finders::Scope::MULTI_VALUE_METHODS.each do |multi_values|
    it "should have #{multi_values} as an empty array as default" do
      subject.send(multi_values+"_values").should == []
    end
  end

  MassiveRecord::ORM::Finders::Scope::SINGLE_VALUE_METHODS.each do |singel_value|
    it "should have #{singel_value} as nil as default" do
      subject.send(singel_value+"_value").should be_nil
    end
  end


  describe "scoping methods" do
    (MassiveRecord::ORM::Finders::Scope::MULTI_VALUE_METHODS + MassiveRecord::ORM::Finders::Scope::SINGLE_VALUE_METHODS).each do |method|
      it { should respond_to(method) }

      it "should return an instance of self #{method}()" do
        subject.send(method, nil).should be_instance_of described_class
      end
    end



    describe "multi value methods" do
      describe "select" do
        it "should not add nil values" do
          subject.select(nil).select_values.should be_empty
        end

        it "should add incomming value to list" do
          subject.select(:info).select_values.should include 'info'
        end

        it "should be adding values if called twice" do
          subject.select(:info).select(:base).select_values.should include 'info', 'base'
        end

        it "should add multiple arguments" do
          subject.select(:info, :base).select_values.should include 'info', 'base'
        end

        it "should add multiple values given as array" do
          subject.select([:info, :base]).select_values.should include 'info', 'base'
        end

        it "should not add same value twice" do
          subject.select(:info).select('info').select_values.should == ['info']
        end
      end
    end



    describe "singel value methods" do
      describe "limit" do
        it "should set a limit" do
          subject.limit(5).limit_value.should == 5
        end

        it "should be set to the last value set" do
          subject.limit(1).limit(5).limit_value.should == 5
        end
      end

      describe "starts_with" do
        it "should set a starts_with" do
          subject.starts_with(5).starts_with_value.should == 5
        end

        it "should be set to the last value set" do
          subject.starts_with(1).starts_with(5).starts_with_value.should == 5
        end
      end

      describe "offset" do
        it "should set a offset" do
          subject.offset(5).offset_value.should == 5
        end

        it "should be set to the last value set" do
          subject.offset(1).offset(5).offset_value.should == 5
        end
      end
    end
  end


  describe "#find_options" do
    it "should return an empty hash when no limitations are set" do
      subject.send(:find_options).should == {}
    end

    it "should include a limit if asked to be limited" do
      subject.limit(5).send(:find_options).should include :limit => 5
    end

    it "should include selection when asked for it" do
      subject.select(:info).send(:find_options).should include :select => ['info']
    end

    it "includes a starts_with when asked for it" do
      subject.starts_with("id-something").send(:find_options).should include :starts_with => "id-something"
    end

    it "includes an offset when asked for it" do
      subject.offset("id-something").send(:find_options).should include :offset => "id-something"
    end
  end


  describe "loaded" do
    it { should_not be_loaded }

    it "should be loaded if set to true" do
       subject.loaded = true
       should be_loaded
    end
  end

  describe "#reset" do
    it "resets the loaded status" do
      subject.loaded = true
      subject.reset
      should_not be_loaded
    end

    it "resets the loaded records" do
      records = [:foo]
      subject.instance_variable_set(:@records, records)
      subject.reset
      subject.instance_variable_get(:@records).should be_empty
    end
  end

  describe "a clone" do
    it "resets the state after being cloned" do
      records = [:foo]
      subject.instance_variable_set(:@records, records)
      subject.loaded = true

      cloned = subject.clone
      cloned.should_not be_loaded
      cloned.instance_variable_get(:@records).should be_empty
    end
  end

  describe "#to_a" do
    it "should return @records if loaded" do
      records = [:foo]
      subject.instance_variable_set(:@records, records)
      subject.loaded = true

      subject.to_a.should == records
    end


    [:to_xml, :to_yaml, :length, :size, :collect, :map, :each, :all?, :include?].each do |method|
      it "should delegate #{method} to to_a" do
        records = []
        records.should_receive(method)

        subject.instance_variable_set(:@records, records)
        subject.loaded = true

        subject.send(method)
      end
    end

    it "should always return an array, even though results are single object" do
      record = mock(Object)
      subject.should_receive(:load_records).and_return(record)
      subject.to_a.should be_instance_of Array
    end
  end

  describe "#find" do
    it "should return nil if not found" do
      klass = mock(Object)
      klass.should_receive(:do_find).and_return(nil)
      subject.should_receive(:klass).and_return(klass)

      subject.find(1).should be_nil
    end

    it "should be possible to add scopes" do
      klass = mock(Object)
      klass.should_receive(:do_find).with(1, :select => ['foo']).and_return(nil)
      subject.should_receive(:klass).and_return(klass)
      subject.select(:foo).find(1)
    end

    it "should include finder options" do
      extra_options = {:select => ["foo"], :conditions => 'should_be_passed_on_to_finder'}
      klass = mock(Object)
      klass.should_receive(:do_find).with("ID", hash_including(extra_options)).and_return([])
      subject.instance_variable_set(:@klass, klass)
      
      subject.find("ID", extra_options)
    end
  end



  describe "#first" do
    it "should return first record if loaded" do
      records = []
      records.should_receive(:first).and_return(:first_record)
      subject.instance_variable_set(:@records, records)
      subject.loaded = true

      subject.first.should == :first_record
    end

    it "should include finder options" do
      extra_options = {:select => ["foo"], :conditions => 'should_be_passed_on_to_finder'}

      klass = mock(Object)
      klass.should_receive(:do_find).with(anything, hash_including(extra_options)).and_return([])
      subject.instance_variable_set(:@klass, klass)

      subject.first(extra_options)
    end
  end

  describe "#all" do
    it "should simply call to_a" do
      subject.should_receive(:to_a).and_return []
      subject.all
    end


    it "should include finder options" do
      extra_options = {:select => ["foo"], :conditions => 'should_be_passed_on_to_finder'}

      klass = mock(Object)
      klass.should_receive(:do_find).with(anything, extra_options)
      subject.instance_variable_set(:@klass, klass)

      subject.all(extra_options)
    end
  end


  describe "#==" do
    it "should be counted equal if it's records are the same as asked what being compared to" do
      subject.instance_variable_set(:@records, [:foo])
      subject.loaded = true

      subject.==([:foo]).should == true
    end
  end



  describe "real world test" do
    include SetUpHbaseConnectionBeforeAll
    include SetTableNamesToTestTable

    describe "with a person" do
      let(:person_1) { Person.create "ID1", :name => "Person1", :email => "one@person.com", :age => 11, :points => 111, :status => true }
      let(:person_2) { Person.create "ID2", :name => "Person2", :email => "two@person.com", :age => 22, :points => 222, :status => false }
      let(:person_3) { Person.create "other", :name => "Person3", :email => "three@person.com", :age => 33, :points => 333, :status => true }

      before do
        person_1.save!
        person_2.save!
        person_3.save!
      end

      (MassiveRecord::ORM::Finders::Scope::MULTI_VALUE_METHODS + MassiveRecord::ORM::Finders::Scope::SINGLE_VALUE_METHODS).each do |method|
        it "should not load from database when Person.#{method}() is called" do
          Person.should_not_receive(:find)
          Person.send(method, 5)
        end
      end

      it "should find just one record when asked for it" do
        Person.limit(1).should == [person_1]
      end

      it "should find only selected column families when asked for it" do
        records = Person.select(:info).limit(1)
        person_from_db = records.first

        person_from_db.points.should be_nil
        person_from_db.status.should be_nil
      end

      it "applying scope on a loaded scope returns a cloned and reset scope" do
        scope = Person.limit(2)
        scope.all.should eq [person_1, person_2]
        scope.should be_loaded

        new_scope = scope.offset("ID2")
        new_scope.should_not be_loaded
        new_scope.all.should eq [person_2, person_3]
      end

      it "should not return read only objects when select is used" do
        person = Person.select(:info).first
        person.should_not be_readonly
      end

      it "ensures records starts with string" do
        Person.starts_with("ID").should == [person_1, person_2]
      end

      it "sets an offset point to begin read rows from" do
        Person.offset("ID2").should == [person_2, person_3]
      end

      it "should be possible to iterate over a collection with each" do
        result = []

        Person.starts_with("ID").limit(2).each do |person|
          result << person.name
        end

        result.should == ["Person1", "Person2"]
      end

      it "should be possible to collect" do
        Person.select(:info).collect(&:name).should == ["Person1", "Person2", "Person3"]
      end

      it "should be possible to checkc if it includes something" do
        Person.limit(1).include?(person_2).should be_false
      end
    end
  end


  describe "#apply_finder_options" do
    it "should apply limit correctly" do
      scope = subject.send :apply_finder_options, :limit => 30
      scope.limit_value.should eq 30
    end

    it "should apply select correctly" do
      scope = subject.send :apply_finder_options, :select => :foo
      scope.select_values.should include 'foo'
    end

    it "should raise unknown scope error if options is unkown" do
      lambda { subject.send(:apply_finder_options, :unkown => false) }.should_not raise_error
    end
  end
end
