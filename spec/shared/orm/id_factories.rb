require 'spec_helper'

shared_examples_for 'an id factory' do
  it "is a singleton" do
    MassiveRecord::ORM::IdFactory::AtomicIncrementation.included_modules.should include(Singleton)
  end

  describe "#next_for" do
    it "responds_to next_for" do
      subject.should respond_to :next_for
    end

    it "uses incomming table name if it's a string" do
      subject.should_receive(:next_id).with(hash_including(:table => "test_table"))
      subject.next_for "test_table"
    end

    it "usees incomming table name if it's a symbol" do
      subject.should_receive(:next_id).with(hash_including(:table => "test_table"))
      subject.next_for :test_table
    end

    it "asks object for it's table name if it responds to that" do
      Person.should_receive(:table_name).any_number_of_times.and_return("people")
      subject.should_receive(:next_id).with(hash_including(:table => "people"))
      subject.next_for(Person)
    end

    it "returns uniq ids" do
      ids = 10.times.inject([]) do |ids|
        ids << subject.next_for(Person)
      end

      ids.uniq.should eq ids
    end
  end

  describe ".next_for" do
    it "delegates to it's instance" do
      subject.should_receive(:next_for).with("cars")
      described_class.next_for("cars")
    end
  end
end
