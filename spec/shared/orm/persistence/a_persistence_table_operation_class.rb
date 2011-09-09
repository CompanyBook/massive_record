shared_examples_for "a persistence table operation class" do
  it_should_behave_like "a persistence operation class"

  describe described_class do
    subject { described_class }

    its(:included_modules) {
      should include MassiveRecord::ORM::Persistence::Operations::TableOperationHelpers
    }
  end
end
