require 'spec_helper'
require 'orm/models/person'

describe MassiveRecord::ORM::IdFactory::Timestamp do
  subject { described_class.instance }

  it_should_behave_like "an id factory"


  describe "settings" do
    after do
      described_class.precision = :microseconds
      described_class.reverse_time = true
    end

    describe "#precision" do
      it "can be set to seconds" do
        described_class.precision = :seconds
        subject.next_for(Person).length.should eq 10
      end

      it "can be set to milliseconds" do
        described_class.precision = :milliseconds
        subject.next_for(Person).length.should eq 13
      end

      it "can be set to microseconds" do
        described_class.precision = :microseconds
        subject.next_for(Person).length.should eq 16
      end
    end

    describe "#reverse_time" do
      let(:time) { mock(Time) }

      before do
        time.stub_chain(:getutc, :to_f).and_return(1)
        Time.stub(:now).and_return time
      end

      it "can be normal time" do
        described_class.reverse_time = false
        described_class.precision = :seconds

        subject.next_for(Person).should eq "1"

        described_class.reverse_time = true
        described_class.precision = :microseconds
      end

      it "can be reverse time" do
        described_class.reverse_time = true
        described_class.precision = :seconds

        subject.next_for(Person).should eq "9999999998"

        described_class.precision = :microseconds
      end
    end
  end
end
