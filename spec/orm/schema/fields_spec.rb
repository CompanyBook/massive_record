require 'spec_helper'

describe MassiveRecord::ORM::Schema::Fields do
  before do
    @fields = MassiveRecord::ORM::Schema::Fields.new
  end

  it "should be a kind of set" do
    @fields.should be_a_kind_of Set
  end
end
