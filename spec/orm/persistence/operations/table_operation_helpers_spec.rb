require 'spec_helper'

module MassiveRecord
  module ORM
    module Persistence
      module Operations


        class TestTableOperationHelpers
          include Operations, TableOperationHelpers
        end


        describe TableOperationHelpers do
          include MockMassiveRecordConnection

          let(:record) { Person.new("id-1") }
          let(:options) { {:this => 'hash', :has => 'options'} }
          
          subject { TestTableOperationHelpers.new(record, options) }

          
          describe "#row_for_record" do
            it "raises an error if id for record is blank" do
              record.id = nil
              expect { subject.row_for_record }.to raise_error MassiveRecord::ORM::IdMissing
            end

            it "returns a row with id and table set" do
              row = subject.row_for_record
              row.id.should eq record.id
              row.table.should eq record.class.table
            end
          end

          describe "#attributes_to_row_values_hash" do
            it "should include the 'pts' field in the database which has 'points' as an alias" do
              subject.attributes_to_row_values_hash["base"].keys.should include("pts")
              subject.attributes_to_row_values_hash["base"].keys.should_not include("points")
            end

            it "should include integer value, even if it is set as string" do
              record.age = "20"
              subject.attributes_to_row_values_hash["info"]["age"].should == 20
            end
          end



          describe "#store_record_to_database" do
            let(:row) { mock(Object, :save => true, :values= => true) }

            before { subject.should_receive(:row_for_record).and_return(row) }

            it "assigns row it's values from what attributes_to_row_values_hash returns" do
              row.should_receive(:values=).with(subject.attributes_to_row_values_hash)
              subject.store_record_to_database('create')
            end

            it "calls save on the row" do
              row.should_receive(:save)
              subject.store_record_to_database('create')
            end
          end
        end



      end
    end
  end
end
