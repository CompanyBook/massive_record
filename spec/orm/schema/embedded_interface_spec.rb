require 'spec_helper'

class TestEmbeddedInterface
  include MassiveRecord::ORM::Schema::EmbeddedInterface
end

describe MassiveRecord::ORM::Schema::EmbeddedInterface do
  after do
    TestEmbeddedInterface.fields = nil
  end

  it "should respond_to default_attributes_from_schema" do
    TestEmbeddedInterface.should respond_to :default_attributes_from_schema
  end

  it "should have fields set to nil if no fields are defined" do
    TestEmbeddedInterface.fields.should be_nil
  end

  it "should have one field if one field is added" do
    class TestEmbeddedInterface
      field :field_name, :string
    end

    TestEmbeddedInterface.should have(1).fields
    TestEmbeddedInterface.fields.first.name.should == "field_name"
  end

  it "should not be possible to have to fields with the same name" do
    lambda {
      class TestEmbeddedInterface
        field :will_raise_error
        field :will_raise_error
      end
    }.should raise_error MassiveRecord::ORM::Schema::InvalidField
  end

  it "should return attributes schema based on DSL" do
    class TestEmbeddedInterface
      field :name
      field :age, :integer, :default => 1
    end

    TestEmbeddedInterface.attributes_schema["name"].type.should == :string
    TestEmbeddedInterface.attributes_schema["age"].type.should == :integer
    TestEmbeddedInterface.attributes_schema["age"].default.should == 1
  end

  it "should make attributes_schema readable from instances" do
    class TestEmbeddedInterface
      field :name
    end

    TestEmbeddedInterface.new.attributes_schema["name"].type.should == :string
  end

  it "should have a list of known attribute names" do
    class TestEmbeddedInterface
      field :name, :string
      field :age, :integer
    end

    TestEmbeddedInterface.should have(2).known_attribute_names
    TestEmbeddedInterface.known_attribute_names.should include("name", "age")
  end

  it "should make known_attribute_names readable for instances" do
    class TestEmbeddedInterface
      field :name, :string
    end

    TestEmbeddedInterface.new.known_attribute_names.should include('name')
  end


  it "should give us default attributes from schema" do
    class TestEmbeddedInterface
      field :name
      field :age, :integer, :default => 1
    end

    defaults = TestEmbeddedInterface.default_attributes_from_schema
    defaults["name"].should be_nil
    defaults["age"].should == 1
  end

  describe "timestamps" do
    before do
      class TestEmbeddedInterface
        timestamps
      end
    end

    it "should have a created_at time field" do
      TestEmbeddedInterface.attributes_schema['created_at'].type.should == :time
    end

    it "should have an updated_at time field" do
      TestEmbeddedInterface.attributes_schema['updated_at'].type.should == :time
    end
  end


  describe "dynamically adding a field" do
    it "should be possible to dynamically add a field" do
      TestEmbeddedInterface.add_field :name, :default => "NA"

      TestEmbeddedInterface.should have(1).fields

      field = TestEmbeddedInterface.fields.first

      field.name.should == "name"
      field.default.should == "NA"
    end

    it "should be possible to set field's type just like the DSL" do
      TestEmbeddedInterface.add_field :age, :integer, :default => 0

      TestEmbeddedInterface.fields.first.name.should == "age"
      TestEmbeddedInterface.fields.first.type.should == :integer
      TestEmbeddedInterface.fields.first.default.should == 0
    end

    it "should call class' undefine_attribute_methods to make sure it regenerates for newly added" do
      TestEmbeddedInterface.should_receive(:undefine_attribute_methods)
      TestEmbeddedInterface.add_field :name, :default => "NA"
    end

    it "should return the new field" do
      field = TestEmbeddedInterface.add_field :age, :integer, :default => 0
      field.should == TestEmbeddedInterface.fields.first
    end

    it "should insert the new field's default value right away" do
      test_interface = TestEmbeddedInterface.new
      test_interface.should_receive("age=").with(1)
      test_interface.add_field :age, :integer, :default => 1
    end
  end

  describe "#attributes_db_raw_data_hash" do
    subject { Address.new("id", :street => "Asker", :number => 2, :nice_place => true, :zip => '1384') }

    it "returns hash with correct key-value pairs" do
      subject.attributes_db_raw_data_hash.should eq({
        "street" => "Asker",
        "number" => 2,
        "nice_place" => "true",
        "postal_code" => "1384"
      })
    end
  end

  describe ".transpose_raw_data_to_record_attributes_and_raw_data" do
    let(:id) { "id" }
    let(:raw_data) do
      MassiveRecord::ORM::RawData.new(value: {
        "street" => "Oslo",
        "number" => 3,
        "nice_place" => "false",
        "postal_code" => "1111"
      })
    end

    it "returns attributes" do
      attributes, raw = Address.transpose_raw_data_to_record_attributes_and_raw_data id, raw_data
      attributes.should eq({:id=>"id", "street"=>"Oslo", "number"=>3, "nice_place"=>false, "zip"=>"1111"})
    end

    it "returns raw data" do
      attributes, raw = Address.transpose_raw_data_to_record_attributes_and_raw_data id, raw_data
      raw.should eq Hash[raw_data.value.collect do |attr, value|
        [attr, MassiveRecord::ORM::RawData.new(value: value, created_at: raw_data.created_at)]
      end]
    end

    it "returns correct attributes from serialized db values hash" do
      attributes, raw = Address.transpose_raw_data_to_record_attributes_and_raw_data(
        id,
        MassiveRecord::ORM::RawData.new(value: MassiveRecord::ORM::Base.coder.dump(raw_data.value))
      )
      attributes.should eq({:id=>"id", "street"=>"Oslo", "number"=>3, "nice_place"=>false, "zip"=>"1111"})
    end
  end
end
