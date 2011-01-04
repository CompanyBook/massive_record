require 'spec_helper'

describe MassiveRecord::ORM::Schema::Field do
  describe "initializer" do
    %w(name column default).each do |attr_name|
      it "should set #{attr_name}" do
        field = MassiveRecord::ORM::Schema::Field.new attr_name => "a_value"
        field.send(attr_name).should == "a_value"
      end
    end

    it "should set type, cast it to a symbol" do
      MassiveRecord::ORM::Schema::Field.new(:type => "a_value").type.should == :a_value
    end

    it "should default to type string" do
      MassiveRecord::ORM::Schema::Field.new(:name => "a_value").type.should == :string
    end
  end

  describe "new_with_arguments_from_dsl" do
    it "should take the first argument as name" do
      field = MassiveRecord::ORM::Schema::Field.new_with_arguments_from_dsl("info")
      field.name.should == "info"
    end

    it "should take the second argument as type" do
      field = MassiveRecord::ORM::Schema::Field.new_with_arguments_from_dsl("info", "integer")
      field.type.should == :integer
    end

    it "should take the rest as options" do
      field = MassiveRecord::ORM::Schema::Field.new_with_arguments_from_dsl("info", "integer", :default => 0)
      field.default.should == 0
    end
  end

  describe "validations" do
    before do
      @fields = MassiveRecord::ORM::Schema::Fields.new
      @field = MassiveRecord::ORM::Schema::Field.new :name => "field_name", :fields => @fields
    end

    it "should be valid from before hook" do
      @field.should be_valid
    end

    it "should not be valid if name is blank" do
      @field.send(:name=, nil)
      @field.should_not be_valid
    end
    
    it "should not be valid without fields to belong to" do
      @field.fields = nil
      @field.should_not be_valid
    end

    it "should not be valid if it's parent some how knows that it's name has been taken" do
      @fields.should_receive(:attribute_name_taken?).with("field_name").and_return true
      @field.should_not be_valid
    end

    MassiveRecord::ORM::Schema::Field::TYPES.each do |type|
      it "should be valid with type #{type}" do
        @field.type = type
        @field.should be_valid
      end
    end

    it "should not be valid with foo as type" do
      @field.type = :foo
      @field.should_not be_valid
    end
  end

  it "should cast name to string" do
    field = MassiveRecord::ORM::Schema::Field.new(:name => :name)
    field.name.should == "name"
  end

  it "should compare two column families based on name" do
    field_1 = MassiveRecord::ORM::Schema::Field.new(:name => :name)
    field_2 = MassiveRecord::ORM::Schema::Field.new(:name => :name)

    field_1.should == field_2
    field_1.eql?(field_2).should be_true
  end

  it "should have the same hash value for two families with the same name" do
    field_1 = MassiveRecord::ORM::Schema::Field.new(:name => :name)
    field_2 = MassiveRecord::ORM::Schema::Field.new(:name => :name)

    field_1.hash.should == field_2.hash
  end

  describe "#decode" do
    it "should return vale if value is of correct class" do
      today = Date.today
      @subject = MassiveRecord::ORM::Schema::Field.new(:name => :created_at, :type => :date)
      @subject.decode(today) == today
    end

    it "should decode a boolean value" do
      @subject = MassiveRecord::ORM::Schema::Field.new(:name => :status, :type => :boolean)
      @subject.decode("1").should be_true
      @subject.decode("0").should be_false
      @subject.decode("").should be_nil
      @subject.decode(nil).should be_nil
    end

    it "should decode a string value" do
      @subject = MassiveRecord::ORM::Schema::Field.new(:name => :status, :type => :string)
      @subject.decode("value").should == "value"
      @subject.decode("").should == ""
      @subject.decode(nil).should be_nil
    end

    it "should decode an integer value" do
      @subject = MassiveRecord::ORM::Schema::Field.new(:name => :status, :type => :integer)
      @subject.decode("1").should == 1
      @subject.decode("").should be_nil
      @subject.decode(nil).should be_nil
    end

    it "should decode a date type" do
      today = Date.today
      @subject = MassiveRecord::ORM::Schema::Field.new(:name => :created_at, :type => :date)
      @subject.decode(today.to_s) == today
      @subject.decode("").should be_nil
      @subject.decode(nil).should be_nil
    end
    
    it "should decode a time type" do
      today = Time.now
      @subject = MassiveRecord::ORM::Schema::Field.new(:name => :created_at, :type => :time)
      @subject.decode(today.to_s) == today
      @subject.decode("").should be_nil
      @subject.decode(nil).should be_nil
    end
  end

  describe "#unique_name" do
    before do
      @family = MassiveRecord::ORM::Schema::ColumnFamily.new :name => :info
      @field = MassiveRecord::ORM::Schema::Field.new :name => "field_name"
      @field_with_column = MassiveRecord::ORM::Schema::Field.new :name => "field_name", :column => "fn"
    end

    it "should raise an error if it has no contained_in" do
      lambda { @field.unique_name }.should raise_error "Can't generate a unique name as I don't have a column family!"
    end

    it "should return correct unique name" do
      @family << @field
      @field.unique_name.should == "info:field_name"
    end
    
    it "should return a correct unique name when using column" do
      @family << @field_with_column
      @field_with_column.unique_name.should == "info:fn"
    end
  end

  describe "#column" do
    before do
      @field = MassiveRecord::ORM::Schema::Field.new :name => "field_name"
    end

    it "should default to name" do
      @field.column.should == "field_name"
    end

    it "should be overridable" do
      @field.column = "new"
      @field.column.should == "new"
    end

    it "should be returned as a string" do
      @field.column = :new
      @field.column.should == "new"
    end
  end
end
