require 'spec_helper'

describe "dirty" do
  before do
    @person = Person.new :name => "Alice", :age => 20, :email => "foo@bar.com"
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
    pending

    original_name = @person.name
    @person.name = "Bob"
    @person.name = original_name
    @person.should_not be_changed
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
