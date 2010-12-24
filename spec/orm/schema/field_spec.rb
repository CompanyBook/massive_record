require 'spec_helper'

describe MassiveRecord::ORM::Schema::Field do
  describe "initializer" do
    %w(name column_family column type default).each do |attr_name|
      it "should set #{attr_name}" do
        field = MassiveRecord::ORM::Schema::Field.new attr_name => "a_value"
        field.send(attr_name).should == "a_value"
      end
    end
  end
end
