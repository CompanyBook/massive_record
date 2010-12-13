require 'spec_helper'
require 'orm/models/test_class'
require 'active_support/secure_random'

describe "persistance" do
  describe "state" do
    include MockMassiveRecordConnection

    it "should be a new record when calling new" do
      TestClass.new.should be_new_record
    end

    it "should not be persisted when new record" do
      TestClass.new.should_not be_persisted
    end

    it "should be persisted if saved" do
      model = TestClass.new :id => "id1"
      model.save
      model.should be_persisted
    end

    it "should be destroyed when destroyed" do
      model = TestClass.new :id => "id1"
      model.save
      model.destroy
      model.should be_destroyed
    end

    it "should not be persisted if destroyed" do
      model = TestClass.new :id => "id1"
      model.save
      model.destroy
      model.should_not be_persisted
    end

    it "should be possible to create new objects" do
      TestClass.create(:id => "id1").should be_persisted
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

    it "should not be considered changed after reload" do
      original_name = @person.name
      @person.name = original_name + original_name
      @person.reload
      @person.should_not be_changed
    end

    it "should return self" do
      @person.reload.should == @person
    end

    it "should raise error on new record" do
      lambda { Person.new.reload }.should raise_error MassiveRecord::ORM::RecordNotFound
    end
  end


  describe "#row_for_record" do
    include MockMassiveRecordConnection

    it "should raise error if id is not set" do
      lambda { Person.new.send(:row_for_record) }.should raise_error MassiveRecord::ORM::IdMissing
    end

    it "should return a row with id set" do
      Person.new({:id => "foo"}).send(:row_for_record).id.should == "foo"
    end

    it "should return a row with table set" do
      Person.new({:id => "foo"}).send(:row_for_record).table.should == Person.table
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
        person = Person.new :id => 14, :name => "Bob", :age => 33
        person.should_receive(:new_record?).and_return(false)
        person.should_receive(:update)
        person.save
      end
    end

    describe "database test" do
      include SetUpHbaseConnectionBeforeAll
      
      describe "create" do
        describe "when table does not exists" do
          before do
            @new_class = "Person_new_#{ActiveSupport::SecureRandom.hex(5)}"
            @new_class = Object.const_set(@new_class, Class.new(MassiveRecord::ORM::Table))
            
            @new_class.instance_eval do
              column_family :bar do
                field :foo
              end
            end

            @new_instance = @new_class.new :id => "id_of_foo", :foo => "bar"
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
            @new_class.table.fetch_column_families.collect(&:name).should == ["bar"]
          end

          it "should store the new instance" do
            @new_instance.save
            @new_class.find(@new_instance.id).should == @new_instance
          end
        end


        describe "when table exists" do
          include CreatePersonBeforeEach

          it "should store (create) new objects" do
            person = Person.new :id => "new_id", :name => "Thorbjorn", :age => "22"
            person.save!
            person_from_db = Person.find(person.id)
            person_from_db.should == person
            person_from_db.name.should == "Thorbjorn"
          end
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
          row = MassiveRecord::Wrapper::Row.new({:id => @person.id, :table => @person.class.table})
          row.should_receive(:values=).with({:info => {"name" => @new_name}})
          @person.should_receive(:row_for_record).and_return(row)

          @person.name = @new_name
          @person.save
        end

        it "should persist the changes" do
          @person.name = @new_name
          @person.save

          Person.find(@person.id).name.should == @new_name
        end

        it "should not have any changes after save" do
          @person.name = @new_name
          @person.save
          @person.should_not be_changed # ..as it has been stored..
        end

        it "should raise error if column familiy needed does not exist" do
          Person.instance_eval do
            column_family :new do
              field :new
            end
          end

          @person = Person.find(@person.id)
          @person.new = "new"
          lambda { @person.save }.should raise_error MassiveRecord::ORM::ColumnFamiliesMissingError

          # Clen up the inserted column family above
          # TODO  Might want to wrap this inside of the column families object?
          Person.instance_eval do
            attributes_schema.delete("new")
            column_families.delete_if { |family| family.name == :new }
          end
        end
      end
    end
  end




  describe "remove record" do
    describe "dry run" do
      include MockMassiveRecordConnection

      before do
        @person = Person.new :id => "id1"
        @person.stub!(:new_record?).and_return(false)
        @row = MassiveRecord::Wrapper::Row.new({:id => @person.id, :table => @person.class.table})
        @person.should_receive(:row_for_record).and_return(@row)
      end


      it "should not be destroyed if wrapper returns false" do
        @row.should_receive(:destroy).and_return(false)
        @person.destroy
        @person.should_not be_destroyed
      end

      it "should be destroyed if wrapper returns true" do
        @row.should_receive(:destroy).and_return(true)
        @person.destroy
        @person.should be_destroyed
      end

      it "should be frozen after destroy" do
        @person.destroy
        @person.should be_frozen
      end

      it "should be frozen after delete" do
        @person.delete
        @person.should be_frozen
      end
      
      it "should not be frozen if wrapper returns false" do
        @row.should_receive(:destroy).and_return(false)
        @person.destroy
        @person.should_not be_frozen
      end
    end

    describe "database test" do
      include SetUpHbaseConnectionBeforeAll
      include SetPersonsTableNameToTestTable

      before do
        @person = Person.create! :id => "id1", :name => "Thorbjorn", :age => 29
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

      describe "#destroy_all" do
        it "should remove all when calling remove_all" do
          Person.create! :id => "id2", :name => "Going to die :-(", :age => 99
          Person.destroy_all
          Person.all.length.should == 0
        end

        it "should return an array of all removed objects" do
          Person.destroy_all.should == [@person]
        end
      end
    end
  end
end
