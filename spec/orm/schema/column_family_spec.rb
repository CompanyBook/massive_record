require 'spec_helper'

describe MassiveRecord::ORM::Schema::ColumnFamily do
  it "should be a kind of set" do
    MassiveRecord::ORM::Schema::ColumnFamily.new.should be_a_kind_of Hash
  end
end
