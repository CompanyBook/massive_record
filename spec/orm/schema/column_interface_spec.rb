require 'spec_helper'

class TestColumnInterface
  include MassiveRecord::ORM::Schema::ColumnInterface
end

describe MassiveRecord::ORM::Schema::TableInterface do
  it "should respond_to default_attributes_from_schema" do
    TestColumnInterface.should respond_to :default_attributes_from_schema
  end
end
