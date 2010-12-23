require 'spec_helper'

describe MassiveRecord::ORM::Schema::ColumnFamilies do
  it "should be a kind of set" do
    MassiveRecord::ORM::Schema::ColumnFamilies.new.should be_a_kind_of Set
  end
end
