require 'spec_helper'

describe MassiveRecord::ORM::Coders::JSON do
  it_should_behave_like "an orm coder"

  [1, "1", ["foo"], {'foo' => 'bar', "1" => 3}, {'nested' => {'inner' => 'secret'}}].each do |value|
    it "should dump a #{value.class} correctly" do
      subject.dump(value).should == ActiveSupport::JSON.encode(value)
    end

    it "should load a #{value.class} correctly" do
      subject.load(ActiveSupport::JSON.encode(value)).should == value
    end
  end
end
