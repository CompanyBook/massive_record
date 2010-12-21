require 'spec_helper'

describe "dirty" do
  describe "dry run" do
    include MockMassiveRecordConnection

    before do
      @person = Person.new :id => 1, :name => "Alice", :age => 20, :email => "foo@bar.com"
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
