shared_examples_for "an orm coder" do
  it { should respond_to :load }
  it { should respond_to :dump }
end
