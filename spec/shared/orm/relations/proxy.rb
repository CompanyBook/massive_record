shared_examples_for "relation proxy" do
  let(:target) { mock(Object).as_null_object }

  before do
    subject.metadata = mock(MassiveRecord::ORM::Relations::Metadata, :find_with => nil).as_null_object if subject.metadata.nil?
  end

  %w(owner target metadata).each do |method|
    it "should respond to #{method}" do
      should respond_to method
    end
  end

  it "should be setting values by initializer" do
    proxy = MassiveRecord::ORM::Relations::Proxy.new(:owner => "owner", :target => target, :metadata => "metadata")
    proxy.owner.should == "owner"
    proxy.target.should == target
    proxy.metadata.should == "metadata"
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
      subject.target = target
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
      subject.should_receive(:can_find_target?).and_return true
      subject.should_receive(:find_target) { target }
      subject.reload.should == target
    end

    it "should return nil if loading of target failed" do
      subject.stub(:can_find_target?).and_return true
      subject.should_receive(:find_target).and_raise MassiveRecord::ORM::RecordNotFound
      subject.reload.should be_nil
    end
  end


  describe "forward method calls to target" do
    let(:target) { mock(Object, :target_method => "return value", :id => "dummy-id") }

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
        target.should_receive(:target_method).and_return(target)
        subject.target_method.should == target
      end

      it "should rause no method error if no one responds to it" do
        lambda { subject.dummy_method_which_does_not_exists }.should raise_error NoMethodError
      end
    end
  end


  describe "target" do
    it "should return the target if it is present" do
      subject.target = target
      subject.target.should == target
    end

    it "should be consodered loaded if a target has been set" do
      subject.target = target
      should be_loaded
    end

    it "should not try to load target if it has been loaded" do
      subject.loaded!
      should_not_receive :find_target
      subject.load_target.should be_nil
    end

    it "should try to load the target if it has not been loaded" do
      subject.stub(:can_find_target?).and_return true
      subject.should_receive(:find_target) { target }
      subject.load_target
      subject.target.should == target
    end

    it "should reset proxy if target's record was not found" do
      subject.stub(:can_find_target?).and_return true
      subject.should_receive(:find_target).and_raise MassiveRecord::ORM::RecordNotFound
      subject.load_target.should be_nil
    end
  end


  describe "replace" do
    let (:old_target) { subject.target_class.new }
    let (:new_target) { subject.target_class.new }

    before do
      subject.target = old_target
    end

    it "should replace the old target with the new one" do
      subject.replace(new_target)
      subject.target.should == new_target
    end

    it "should reset the proxy if asked to replace with nil" do
      subject.should_receive(:reset)
      subject.replace(nil)
    end
  end

  describe "find_with" do
    let(:metadata) { MassiveRecord::ORM::Relations::Metadata.new 'name', :find_with => Proc.new { |target| Person.find("testing-123") }}
    let(:person) { Person.new }

    before do
      subject.metadata = metadata
      subject.stub(:can_find_target?).and_return(true)
    end

    it "should use metadata's find with if exists" do
      Person.should_receive(:find).with("testing-123").and_return(person)

      should_not_receive :find_target
      subject.load_target 
    end
  end
end
