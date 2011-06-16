require 'spec_helper'

describe "dirty" do
  describe "dry run" do
    include MockMassiveRecordConnection

    before do
      @person = Person.new '1', :name => "Alice", :age => 20, :email => "foo@bar.com"
    end

    it "should not be changed after created" do
      @person.should_not be_changed
    end

    it "should not be changed if attribute is set to what it currently is" do
      @person.name = "Alice"
      @person.should_not be_changed
    end

    it "should notice changes" do
      @person.name = "Bob"
      @person.should be_changed
    end

    it "should notice changes in boolean values from false to true" do
      @person.status = !@person.status
      @person.should be_status_changed
    end

    it "should notice changes in boolean values from true to false" do
      @person.status = true
      @person.save
      @person.status = false
      @person.should be_status_changed
    end

    it "should not consider age set as string to the same as integer a change" do
      @person.age = "20"
      @person.should_not be_age_changed
    end

    it "should not consider age set as string back to original value a change" do
      @person.age = 30
      @person.age = "20"
      @person.should_not be_age_changed
    end


    it "should know when a attribute is set to it's original value" do
      original_name = @person.name
      @person.name = "Bob"
      @person.name = original_name
      @person.should_not be_changed
    end

    it "should always keep the objects original value as _was" do
      original_name = @person.name
      @person.name = "Bob"
      @person.name = "Foo"
      @person.name_was.should == original_name
    end

    it "should return what name was" do
      @person.name = "Bob"
      @person.name_was.should == "Alice"
    end


    describe "should reset changes" do
      it "on save" do
        @person.name = "Bob"
        @person.save
        @person.should_not be_changed
      end

      it "on save, but don't do it if save fails validation" do
        @person.should_receive(:valid?).and_return(false)
        @person.name = "Bob"
        @person.save
        @person.should be_changed
      end

      it "on save!" do
        @person.name = "Bob"
        @person.save!
        @person.should_not be_changed
      end

      it "on reload" do
        @person.name = "Bob"
        @person.reload
        @person.should_not be_changed
      end
    end

    describe "previous changes" do
      it "should be blank before save" do
        @person.previous_changes.should be_blank
      end

      it "should equal to changes before save" do
        @person.name = "Bob"
        changes_before_save = @person.changes

        @person.save

        @person.changes.should be_empty
        @person.previous_changes.should == changes_before_save
      end

      it "should equal to changes before save!" do
        @person.name = "Bob"
        changes_before_save = @person.changes

        @person.save!

        @person.changes.should be_empty
        @person.previous_changes.should == changes_before_save
      end

      it "should be nil after a reload" do
        @person.name = "Bob"
        @person.save
        @person.reload
        @person.previous_changes.should be_blank
      end
    end
  end


  describe "database run" do
    include SetUpHbaseConnectionBeforeAll
    include SetTableNamesToTestTable

    before do
      @person = Person.new
      @person.id = "test"
      @person.points = "25"
      @person.date_of_birth = "19850730"
      @person.status = "0"
    end

    it "should update dirty status correctly after a reload" do
      @person.addresses = {:something => "strage"}
      @person.save! :validate => false
      @person.reload
      @person.addresses = {}
      @person.save! :validate => false
      @person.reload
      @person.addresses.should == {}
    end
  end
end
