shared_examples_for "a persistence operation class" do
  describe described_class do
    subject { described_class }

    its(:included_modules) { should include MassiveRecord::ORM::Persistence::Operations }
  end

  it "responds to execute" do
    subject.execute
  end
end
