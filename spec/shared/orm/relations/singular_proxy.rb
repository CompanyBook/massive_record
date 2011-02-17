shared_examples_for "singular proxy" do
  let(:target) { mock(Object).as_null_object }
  let(:find_target_returns) { subject.represents_a_collection? ? [target] : target }

  before do
    subject.metadata = mock(MassiveRecord::ORM::Relations::Metadata, :find_with => nil).as_null_object if subject.metadata.nil?
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
end
