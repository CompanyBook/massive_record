require 'spec_helper'

describe MassiveRecord::ORM::RawData do
  let(:value) { "FooBar!" }
  let(:created_at) { Time.now.to_s }

  subject { MassiveRecord::ORM::RawData.new(value: value, created_at: created_at) }

  describe "#initialize" do
    it "assigns value" do
      subject.value.should eq value
    end

    it "assigns created_at" do
      subject.created_at.should eq created_at
    end
  end


  describe ".new_with_data_from" do
    describe "thrift cell" do
      let(:cell) { MassiveRecord::Wrapper::Cell.new(value: value, created_at: created_at) }

      subject { described_class.new_with_data_from(cell) }

      it "assigns value" do
        subject.value.should eq value
      end

      it "assigns created_at" do
        subject.created_at.should eq created_at
      end
    end
  end


  describe "#to_s" do
    it "represents itself with it's value" do
      subject.to_s.should eq value
    end
  end

  describe "#inspect" do
    it "represents itself with it's value" do
      subject.inspect.should eq "<#{subject.class} #{subject.value.inspect}>"
    end
  end

  
  describe "equality" do
    it "considered equal if created at and value are the same" do
      cell = described_class.new_with_data_from(
        MassiveRecord::Wrapper::Cell.new(value: value, created_at: created_at)
      )
      cell.should eq subject
    end
  end
end
