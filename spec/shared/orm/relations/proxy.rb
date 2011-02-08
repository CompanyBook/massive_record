shared_examples_for MassiveRecord::ORM::Relations::Proxy do
  %w(owner target metadata).each do |method|
    it "should respond to #{method}" do
      should respond_to method
    end
  end

  describe "#loaded" do
    it "should be true when loaded" do
      subject.instance_variable_set :@loaded, true
      should be_loaded
    end

    it "should be false when not loaded" do
      subject.instance_variable_set :@loaded, false
      should_not be_loaded
    end

    it "should be loaded when loaded! is called" do
      subject.instance_variable_set :@loaded, false
      subject.loaded!
      should be_loaded
    end
  end


  describe "#reset" do
    it "should not be loaded after reset" do
      subject.loaded!
      subject.reset
      should_not be_loaded
    end

    it "should reset the target" do
      subject.target = "foo"
      subject.reset
      subject.stub(:find_target?).and_return(false)
      subject.target.should be_nil
    end
  end

  describe "#reload" do
    before do
      subject.stub!(:find_target)
    end

    it "should reset the proxy" do
      subject.should_receive :reset
      subject.reload
    end

    it "should call load_target" do
      subject.should_receive :load_target
      subject.reload
    end

    it "should return target if loaded successfully" do
      subject.should_receive(:find_target) { "foo" }
      subject.reload.should == "foo"
    end

    it "should return nil if loading of target failed" do
      subject.should_receive(:find_target).and_raise MassiveRecord::ORM::RecordNotFound
      subject.reload.should be_nil
    end
  end


  describe "forward method calls to target" do
    let(:target) { mock(Object, :target_method => "return value") }

    before do
      subject.target = target
    end
    

    describe "#respond_to?" do
      it "should check proxy to see if it responds to something" do
        should respond_to :target
      end
      
      it "should respond to target_method" do
        should respond_to :target_method
      end

      it "should not respond to a dummy method" do
        should_not respond_to :dummy_method_which_does_not_exists 
      end
    end


    describe "#method_missing" do
      it "should call proxy's method if exists in proxy" do
        subject.should_receive(:loaded?).once
        subject.loaded?
      end

      it "should call target's method if it responds to it" do
        target.should_receive(:target_method).and_return("foo")
        subject.target_method.should == "foo"
      end

      it "should rause no method error if no one responds to it" do
        lambda { subject.dummy_method_which_does_not_exists }.should raise_error NoMethodError
      end
    end
  end


  describe "target" do
    it "should return the target if it is present" do
      subject.target = "foo"
      subject.target.should == "foo"
    end

    it "should be consodered loaded if a target has been set" do
      subject.target = "foo"
      should be_loaded
    end

    it "should not try to load target if it has been loaded" do
      subject.loaded!
      should_not_receive :find_target
      subject.target.should be_nil
    end

    it "should try to load the target if it has not been loaded" do
      subject.should_receive(:find_target) { "foo" }
      subject.load_target
      subject.target.should == "foo"
    end

    it "should reset proxy if target's record was not found" do
      subject.should_receive(:find_target).and_raise MassiveRecord::ORM::RecordNotFound
      subject.load_target.should be_nil
    end
  end
end
