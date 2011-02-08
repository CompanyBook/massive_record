shared_examples_for MassiveRecord::ORM::Proxy do
  %w(owner target metadata loaded).each do |method|
    it "should respond to #{method}" do
      should respond_to method
    end
  end

  describe "#loaded?" do
    it "should be true when loaded" do
      subject.loaded = true
      should be_loaded
    end

    it "should be false when not loaded" do
      subject.loaded = false
      should_not be_loaded
    end
  end
end
