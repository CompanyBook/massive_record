require 'spec_helper'

describe MassiveRecord::ORM::Schema::Fields do
  before do
    @fields = MassiveRecord::ORM::Schema::Fields.new
  end

  it "should be a kind of set" do
    @fields.should be_a_kind_of Set
  end

  it "should be possible to add fields" do
    @fields << MassiveRecord::ORM::Schema::Field.new
  end

  it "should not be possible to add two fields with the same name" do
    @fields << MassiveRecord::ORM::Schema::Field.new(:name => "attr")
    @fields.add?(MassiveRecord::ORM::Schema::Field.new(:name => "attr")).should be_nil
  end
end
