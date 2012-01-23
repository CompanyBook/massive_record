require 'spec_helper'

describe "Retryable" do

  let(:retryable) { MassiveRecord::Wrapper::Retryable.new { } }

  describe "rescue" do
    it "should only retry a specified amount of times" do
      MassiveRecord::Wrapper::Retryable.any_instance.should_receive(:sleep_before_retry).exactly(2)
      begin
        MassiveRecord::Wrapper::Retryable.new(:retry => 2, :on => Exception) { raise "Bouh!" } 
      rescue
      end
    end

    it "should only rescue a given exception" do
      lambda { MassiveRecord::Wrapper::Retryable.new(:on => LoadError) { raise StandardError.new("Bouh!") } }.should raise_error(StandardError)
    end
  end

  describe "block" do
    it "should raise an error if no block is passed to the initializer" do
      lambda { MassiveRecord::Wrapper::Retryable.new }.should raise_error(RuntimeError)
    end
      
    it "should process a block without exception" do
      city_name = "Paris"
      
      city_name.should == "Paris"
      MassiveRecord::Wrapper::Retryable.new { city_name = "London" }.should be_a_kind_of(MassiveRecord::Wrapper::Retryable)
      city_name.should == "London"
    end

    it "should retry a block until it works" do
      MassiveRecord::Wrapper::Retryable.any_instance.should_receive(:sleep_before_retry).exactly(2)
      counter = 0
      MassiveRecord::Wrapper::Retryable.new { counter += 1; raise Exception if counter < 3 }
    end
  end

  describe "defaults" do
    it "should default the exception to retry to Exception" do
      retryable.exception_to_retry.should == Exception
    end

    it "should default the maximum amount of retries to 50" do
      retryable.max_retry_count.should == 50
    end

    it "should default the retry count to 0" do
      retryable.current_retry_count.should == 0
    end

    it "should default the sleeping time to 2 seconds" do
      retryable.sleep_in_seconds.should == 2
    end
  end

  describe "sleeping time" do
    before do
      retryable.current_retry_count  = 1
      retryable.sleep_in_seconds = 2
    end

    it "should sleep during which is the ** value of the sleeping time and the retry count" do
      retryable.should_receive(:sleep).with(2)
      retryable.send(:sleep_before_retry)
    end

    it "should log the status of the retry" do
      retryable.logger = Object.new
      retryable.logger.should_receive(:info).with("Exception < Exception > raised... waiting 2 seconds before retry.")
      retryable.send(:sleep_before_retry)
    end

    it "should sleep a maximum of 1 hour" do
      retryable.should_receive(:sleep).with(3600)
      retryable.current_retry_count = 1000000
      retryable.send(:sleep_before_retry)
    end
  end

end
