shared_examples_for "an orm coder" do
  it { should respond_to :load }
  it { should respond_to :dump }

  [1, "1", nil, ["foo"], {'foo' => 'bar', "1" => 3}, {'nested' => {'inner' => 'secret'}}].each do |value|
    it "should dump a #{value.class} correctly" do
      subject.dump(value).should == code_with.call(value)
    end

    it "should load a #{value.class} correctly" do
      subject.load(code_with.call(value)).should == value
    end
  end
end
