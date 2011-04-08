shared_examples_for "singular proxy" do
  let(:proxy_target) { mock(Object).as_null_object }
  let(:find_proxy_target_returns) { subject.represents_a_collection? ? [proxy_target] : proxy_target }

  before do
    subject.metadata = mock(MassiveRecord::ORM::Relations::Metadata, :find_with => nil).as_null_object if subject.metadata.nil?
  end

  describe "forward method calls to proxy_target" do
    let(:proxy_target) { mock(Object, :proxy_target_method => "return value", :id => "dummy-id") }

    before do
      subject.proxy_target = proxy_target
    end
    

    describe "#respond_to?" do
      it "should check proxy to see if it responds to something" do
        should respond_to :proxy_target
      end
      
      it "should respond to proxy_target_method" do
        should respond_to :proxy_target_method
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

      it "should call proxy_target's method if it responds to it" do
        proxy_target.should_receive(:proxy_target_method).and_return(proxy_target)
        subject.proxy_target_method.should == proxy_target
      end

      it "should rause no method error if no one responds to it" do
        lambda { subject.dummy_method_which_does_not_exists }.should raise_error NoMethodError
      end
    end

    describe "comparison of class" do
      let(:proxy_target) { Person.new }

      it "should be answer correctly to which class it is" do
        subject.should be_a(Person)
      end

      it "should be comparable correctly" do
        (Person === subject).should be_true
      end

      it "should be compared correctly in a case when construction" do
        case subject
        when Person
        else
          fail
        end
      end
    end
  end
end
