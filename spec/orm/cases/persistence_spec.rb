require 'spec_helper'
require 'orm/models/test_class'

describe "persistence" do
  describe "state" do
    include MockMassiveRecordConnection

    it "should be a new record when calling new" do
      TestClass.new.should be_new_record
    end

    it "should not be persisted when new record" do
      TestClass.new.should_not be_persisted
    end

    it "should be persisted if saved" do
      model = TestClass.new "id1"
      model.save
      model.should be_persisted
    end

    it "is still a new record if saved to database failed" do
      operation = mock(Object, :execute => false)
      MassiveRecord::ORM::Persistence::Operations.should_receive(:insert).and_return(operation)

      model = TestClass.new "id1"
      model.save
      model.should_not be_persisted
    end

    it "should be destroyed when destroyed" do
      model = TestClass.new "id1"
      model.save
      model.destroy
      model.should be_destroyed
    end

    it "should not be persisted if destroyed" do
      model = TestClass.new "id1"
      model.save
      model.destroy
      model.should_not be_persisted
    end

    it "should not be marked as destroyed if operation failed" do
      operation = mock(Object, :execute => false)
      MassiveRecord::ORM::Persistence::Operations.should_receive(:destroy).and_return(operation)

      model = TestClass.new "id1"
      model.save
      model.destroy
      model.should_not be_destroyed
      model.should_not be_frozen
    end

    it "should be possible to create new objects" do
      TestClass.create("id1").should be_persisted
    end

    it "should raise an error if validation fails on save!" do
      model = TestClass.new
      model.should_receive(:create_or_update).and_return(false)
      lambda { model.save! }.should raise_error MassiveRecord::ORM::RecordNotSaved
    end

    it "should respond to reload" do
      TestClass.new.should respond_to :reload
    end
  end
  


  describe "#reload" do
    include CreatePersonBeforeEach

    before do
      @person = Person.find("ID1")
    end

    it "should reload models attribute" do
      original_name = @person.name
      @person.name = original_name + original_name
      @person.reload
      @person.name.should == original_name
    end

    it "should reload the raw data" do
      @person.name += "_NEW"
      @person.save!
      @person.reload
      @person.raw_data.should eq Person.find("ID1").raw_data
    end

    it "should not be considered changed after reload" do
      original_name = @person.name
      @person.name = original_name + original_name
      @person.reload
      @person.should_not be_changed
    end

    it "should return self" do
      @person.reload.should == @person
    end

    it "should not do anything on reload when record is not persisted" do
      Person.should_not_receive :find
      Person.new.reload
    end
  end
  

  describe "update attribute" do
    describe "dry run" do
      include MockMassiveRecordConnection

      before do
        @person = Person.create! "new_id", :name => "Thorbjorn", :age => "22"
      end

      it "should update given attriubte when valid" do
        @person.update_attribute(:name, "new").should be_true
      end

      it "should update given attribute when invalid" do
        @person.update_attribute(:name, nil).should be_true
      end
    end
  end

  describe "update attributes" do
    describe "dry run" do
      include MockMassiveRecordConnection

      before do
        @person = Person.create! "new_id", :name => "Thorbjorn", :age => "22"
      end

      it "should update given attriubtes when valid" do
        @person.update_attributes(:name => "new", :age => "66").should be_true
      end

      it "should not update given attributes when one is invalid" do
        @person.update_attributes(:name => nil, :age => "66").should be_false
      end

      it "should raise error when called with a bang" do
        lambda { @person.update_attributes!(:name => nil, :age => "66") }.should raise_error MassiveRecord::ORM::RecordInvalid
      end
    end
  end

  describe "save" do
    describe "dry test" do
      include MockMassiveRecordConnection
      
      it "should delegate save to create if its a new record" do
        person = Person.new :name => "Bob", :age => 33
        person.should_receive(:create)
        person.save
      end

      it "should delegate save to update if its a persisted record" do
        person = Person.new '14', :name => "Bob", :age => 33
        person.should_receive(:new_record?).any_number_of_times.and_return(false)
        person.should_receive(:update)
        person.save
      end
    end

    describe "database test" do
      include SetUpHbaseConnectionBeforeAll
      include SetTableNamesToTestTable
      
      describe "create" do
        describe "when table does not exists" do
          before do
            @new_class = "Person_new_#{SecureRandom.hex(5)}"
            @new_class = Object.const_set(@new_class, Class.new(MassiveRecord::ORM::Table))
            
            @new_class.instance_eval do
              column_family :bar do
                field :foo
              end

              column_family :empty_family do
              end
            end

            @new_instance = @new_class.new "id_of_foo", :foo => "bar"
          end

          after do
            @new_class.table.destroy if @connection.tables.include? @new_class.table_name
          end


          it "it should not exists" do
            @connection.tables.should_not include @new_class.table_name
          end

          it "should create the table" do
            @new_instance.save
            @connection.tables.should include @new_class.table_name
          end

          it "should create correct column families" do
            @new_instance.save
            @new_class.table.fetch_column_families.collect(&:name).should include "bar", "empty_family"
          end

          it "should store the new instance" do
            @new_instance.save
            @new_class.find(@new_instance.id).should == @new_instance
          end
        end


        describe "when table exists" do
          include CreatePersonBeforeEach

          it "should store (create) new objects" do
            person = Person.new "new_id", :name => "Thorbjorn", :age => "22"
            person.save!
            person_from_db = Person.find(person.id)
            person_from_db.should == person
            person_from_db.name.should == "Thorbjorn"
          end

          it "creates persists embedded documents" do
            person = Person.new "new_id", :name => "Thorbjorn", :age => "22"
            address = Address.new "address-1", :street => "Asker", :number => 1
            person.addresses << address
            person.save!
            person_from_db = Person.find(person.id)
            person_from_db.addresses.should eq [address]
          end
        end

        it "raises an error if id already exists" do
          check_was = Person.check_record_uniqueness_on_create
          Person.check_record_uniqueness_on_create = true

          Person.create! "foo", :name => "Thorbjorn", :age => "22"
          expect {
            Person.create! "foo", :name => "Anders", :age => "22"
          }.to raise_error MassiveRecord::ORM::RecordNotUnique

          Person.find("foo").name.should eq "Thorbjorn"
          
          Person.check_record_uniqueness_on_create = check_was
        end

        it "raises no error if exist checking is turned off" do
          check_was = Person.check_record_uniqueness_on_create
          Person.check_record_uniqueness_on_create = false

          Person.create! "foo", :name => "Thorbjorn", :age => "22"
          Person.create! "foo", :name => "Anders", :age => "22" # This will result in an "update"
          Person.find("foo").name.should eq "Anders"

          Person.check_record_uniqueness_on_create = check_was
        end
      end

      describe "update" do
        include CreatePersonBeforeEach

        before do
          @person = Person.find("ID1")
          @original_name = @person.name
          @new_name = @original_name + @original_name
        end

        it "should not ask for row for record when no changes have been made (update is done through this object)" do
          @person.should_not_receive(:row_for_record)
          @person.save
        end

        it "should only include changed attributes" do
          MassiveRecord::ORM::Persistence::Operations.should_receive(:update).with(
            @person, hash_including(:attribute_names_to_update => ["positive_as_default", "name"])
          ).and_return(mock(Object, :execute => true))


          @person.name = @new_name
          @person.save
        end

        it "should include changed attributes for embedded objects" do
          MassiveRecord::ORM::Persistence::Operations.should_receive(:update).with(
            @person, hash_including(:attribute_names_to_update => ["positive_as_default", "name", "addresses"])
          ).and_return(mock(Object, :execute => true))

          # Makes the reload raw data do nothing. Reason for this is as follows:
          # We are stubbing out the update operaitons, thus no address are being
          # inserted to the database for this person.
          #
          # The reload_raw_data does a find with select on addresses column family only.
          # When that is being done, and no data is found it will return nil back (Thrift
          # api does this). This will in turn result in a record not found error, which is
          # kinda not what we want.
          @person.addresses.should_receive(:reload_raw_data).any_number_of_times

          @person.name = @new_name
          @person.addresses << Address.new("id1", :street => "foo")
        end

        it "should persist the changes" do
          @person.name = @new_name
          @person.save

          Person.find(@person.id).name.should == @new_name
        end

        it "persists changes in embedded documents" do
          address = Address.new "address-1", :street => "Asker", :number => 1
          @person.addresses << address
          @person.save!

          @person_from_db = Person.find(@person.id)
          @person_from_db.addresses[0].street = "Heggedal"
          @person_from_db.save!

          @person_from_db = Person.find(@person.id)
          @person_from_db.addresses[0].street.should eq "Heggedal"
        end

        it "should not have any changes after save" do
          @person.name = @new_name
          @person.save
          @person.should_not be_changed
        end

        it "has no changes after an embedded object is added and saved" do
          @person.addresses << Address.new("address-1", :street => "Asker", :number => 1)
          @person.save
          @person.should_not be_changed
        end

        it "should raise error if column familiy needed does not exist" do
          Person.instance_eval do
            column_family :new do
              field :new
            end
          end

          expect { @person = Person.find(@person.id) }.to raise_error MassiveRecord::ORM::ColumnFamiliesMissingError

          # Clen up the inserted column family above
          # TODO  Might want to wrap this inside of the column families object?
          Person.instance_eval do
            column_families.delete_if { |family| family.name == "new" }
          end
        end
      end
    end
  end


  describe "remove record" do
    describe "dry run" do
      include MockMassiveRecordConnection

      let(:person) { Person.new "id1" }
      let(:operation) { MassiveRecord::ORM::Persistence::Operations::Destroy.new(person) }

      before do
        person.stub(:new_record?).and_return(false)
        MassiveRecord::ORM::Persistence::Operations.stub(:destroy).and_return operation
      end


      it "should not be destroyed if wrapper returns false" do
        operation.should_receive(:execute).and_return false
        person.destroy
        person.should_not be_destroyed
      end

      it "should be destroyed if wrapper returns true" do
        person.destroy
        person.should be_destroyed
      end

      it "returns destroyed record" do
        person.destroy.should eq person
      end

      it "should be frozen after destroy" do
        person.destroy
        person.should be_frozen
      end

      it "should be frozen after delete" do
        person.delete
        person.should be_frozen
      end
      
      it "should not be frozen if wrapper returns false" do
        operation.should_receive(:execute).and_return false
        person.destroy
        person.should_not be_frozen
      end
    end

    describe "database test" do
      include SetUpHbaseConnectionBeforeAll
      include SetTableNamesToTestTable

      before do
        @person = Person.create! "id1", :name => "Thorbjorn", :age => 29
      end

      it "should be removed by destroy" do
        @person.destroy
        @person.should be_destroyed
        Person.all.length.should == 0
      end

      it "should be removed by delete" do
        @person.delete
        @person.should be_destroyed
        Person.all.length.should == 0
      end
      
      it "should be able to call destroy on new records" do
        person = Person.new
        person.destroy
      end

      describe "#destroy_all" do
        it "should remove all when calling remove_all" do
          Person.create! "id2", :name => "Going to die :-(", :age => 99
          Person.destroy_all
          Person.all.length.should == 0
        end

        it "should return an array of all removed objects" do
          Person.destroy_all.should == [@person]
        end

        it "should destroy all even if it is above 10 rows (obviously)" do
          15.times { |i| Person.create! "id-#{i}", :name => "Going to die :-(", :age => i + 20 }
          Person.destroy_all
          Person.all.length.should == 0
        end
      end
    end
  end



  describe "increment" do
    describe "dry" do
      include MockMassiveRecordConnection

      before do
        @person = Person.create! "id1", :name => "Thorbjorn", :age => 29
      end

      it "should being able to increment age" do
        @person.increment(:age)
        @person.age.should == 30
      end

      it "should be able to increment age by given value" do
        @person.increment(:age, 2)
        @person.age.should == 31
      end

      it "should return object self" do
        @person.increment(:age, 2).should == @person
      end

      it "should support increment values which currently are nil" do
        @person.age = nil
        @person.increment(:age)
        @person.age.should == 1
      end

      it "should complain if users tries to increment non-integer fields" do
        @person.name = nil
        lambda { @person.increment(:name) }.should raise_error MassiveRecord::ORM::NotNumericalFieldError
      end
    end

    describe "with database" do
      include SetUpHbaseConnectionBeforeAll
      include SetTableNamesToTestTable

      before do
        @person = Person.create! "id1", :name => "Thorbjorn", :age => 29
      end

      it "should delegate it's call to increment" do
        @person.should_receive(:increment).with(:age, 1).and_return(@person)
        @person.increment! :age
      end

      it "should update object in database when called with a bang" do
        @person.increment! :age
        @person.reload
        @person.age.should == 30
      end


      describe "atomic increments" do
        it "raises error if called on non integer fields" do
          lambda { @person.atomic_increment!(:name) }.should raise_error MassiveRecord::ORM::NotNumericalFieldError
        end

        it "should be able to do atomic increments on existing objects" do
          @person.atomic_increment!(:age).should == 30
          @person.age.should == 30
          @person.reload
          @person.age.should == 30
        end

        it "is a persisted record after incrementation" do
          person = Person.new('id2')
          person.atomic_increment!(:age).should eq 1
          person.should be_persisted
        end

        it "increments correctly when value is '1'" do
          old_ensure = MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings
          MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings = true

          person = Person.new('id2')
          person.atomic_increment!(:age).should eq 1

          atomic_field = Person.attributes_schema['age']

          # Enter incompatible data, number as string.
          Person.table.find("id2").tap do |row|
            row.update_column(
              atomic_field.column_family.name,
              atomic_field.name,
              MassiveRecord::ORM::Base.coder.dump(1)
            )
            row.save
          end

          person.atomic_increment!(:age).should eq 2

          MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings = old_ensure
        end
      end

      describe "atomic decrements" do
        it "raises error if called on non integer fields" do
          lambda { @person.atomic_decrement!(:name) }.should raise_error MassiveRecord::ORM::NotNumericalFieldError
        end

        it "should be able to do atomic decrements on existing objects" do
          @person.atomic_decrement!(:age).should == 28
          @person.age.should == 28
          @person.reload
          @person.age.should == 28
        end

        it "is a persisted record after decrementation" do
          person = Person.new('id2')
          person.atomic_decrement!(:age).should eq -1
          person.should be_persisted
        end

        it "decrementss correctly when value is '1'" do
          old_ensure = MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings
          MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings = true

          person = Person.new('id2')
          person.atomic_increment!(:age).should eq 1

          atomic_field = Person.attributes_schema['age']

          # Enter incompatible data, number as string.
          Person.table.find("id2").tap do |row|
            row.update_column(
              atomic_field.column_family.name,
              atomic_field.name,
              MassiveRecord::ORM::Base.coder.dump(1)
            )
            row.save
          end

          person.atomic_decrement!(:age).should eq 0

          MassiveRecord::ORM::Base.backward_compatibility_integers_might_be_persisted_as_strings = old_ensure
        end
      end
    end
  end

  describe "decrement" do
    describe "dry" do
      include MockMassiveRecordConnection

      before do
        @person = Person.create! "id1", :name => "Thorbjorn", :age => 29
      end

      it "should being able to decrement age" do
        @person.decrement(:age)
        @person.age.should == 28
      end

      it "should be able to decrement age by given value" do
        @person.decrement(:age, 2)
        @person.age.should == 27
      end

      it "should return object self" do
        @person.decrement(:age, 2).should == @person
      end

      it "should support decrement values which currently are nil" do
        @person.age = nil
        @person.decrement(:age)
        @person.age.should == -1
      end

      it "should complain if users tries to decrement non-integer fields" do
        @person.name = nil
        lambda { @person.decrement(:name) }.should raise_error MassiveRecord::ORM::NotNumericalFieldError
      end
    end

    describe "with database" do
      include SetUpHbaseConnectionBeforeAll
      include SetTableNamesToTestTable

      before do
        @person = Person.create! "id1", :name => "Thorbjorn", :age => 29
      end

      it "should delegate it's call to decrement" do
        @person.should_receive(:decrement).with(:age, 1).and_return(@person)
        @person.decrement! :age
      end

      it "should update object in database when called with a bang" do
        @person.decrement! :age
        @person.reload
        @person.age.should == 28
      end
    end
  end

  describe "read only objects" do
    include MockMassiveRecordConnection

    it "should raise an error if new record is read only and you try to save it" do
      person = Person.new "id1", :name => "Thorbjorn", :age => 29
      person.readonly!
      lambda { person.save }.should raise_error MassiveRecord::ORM::ReadOnlyRecord
    end

    it "should raise an error if record is read only and you try to save it" do
      person = Person.create "id1", :name => "Thorbjorn", :age => 29
      person.should be_persisted

      person.readonly!
      lambda { person.save }.should raise_error MassiveRecord::ORM::ReadOnlyRecord
    end
  end

  describe "id as int" do
    include SetUpHbaseConnectionBeforeAll
    include SetTableNamesToTestTable

    it "saves id as string and reloads correctly" do
      person = Person.new :name => "Thorbjorn", :age => 29
      person.id = 1
      person.save!

      person.reload
      person.id.should == "1"
    end
  end


  describe "attributes with nil value" do
    include SetUpHbaseConnectionBeforeAll
    include SetTableNamesToTestTable


    subject do
      Person.create!("id", {
        :name => "Thorbjorn",
        :age => 22,
        :points => 1,
        :dictionary => {'home' => 'Here'},
        :status => true
      })
    end

    %w(points dictionary status).each do |attr|
      it "removes the cell from hbase when #{attr} is set to nil" do
        subject[attr] = nil
        subject.save!

        raw_values = Person.table.find(subject.id).values
        raw_values[subject.attributes_schema[attr].unique_name].should be_nil
      end
    end
  end
end
