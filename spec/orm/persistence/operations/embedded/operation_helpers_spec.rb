require 'spec_helper'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module Embedded
          class TestEmbeddedOperationHelpers
            include Operations, OperationHelpers
          end

          describe TestEmbeddedOperationHelpers do
            include SetUpHbaseConnectionBeforeAll 
            include SetTableNamesToTestTable

            let(:address) { Address.new("addresss-id", :street => "Asker", :number => 5) }
            let(:person) { Person.new "person-id", :name => "Thorbjorn", :age => "22" }
            let(:options) { {:this => 'hash', :has => 'options'} }


            let(:proxy_for_person) { address.send(:relation_proxy, :person) }

            let(:row) do
              MassiveRecord::Wrapper::Row.new({
                :id => person.id,
                :table => person.class.table
              })
            end


            subject { TestEmbeddedOperationHelpers.new(address, options) }

            before { address.person = person }


            describe "#embedded_in_proxies" do
              it "returns some proxies" do
                subject.embedded_in_proxies.should_not be_empty
              end

              it "returns proxies which represents embedded in relations" do
                subject.embedded_in_proxies.all? { |p| p.metadata.embedded_in? }.should be_true
              end
            end

            describe "#embedded_in_proxy_targets" do
              its(:embedded_in_proxy_targets) { should include person }
            end

            describe "#row_for_record" do
              it "returns row for given record" do
                row = subject.row_for_record(person)
                row.id.should eq person.id
                row.table.should eq person.class.table
              end
            end



            describe "update_embedded" do
              before { subject.stub(:row_for_record).and_return(row) }

              it "ask for record's row" do
                subject.should_receive(:row_for_record).with(person).and_return(row)
                subject.update_embedded(proxy_for_person, "new_value")
              end

              it "sets value on row" do
                row.should_receive(:values=).with(
                  'addresses' => {
                    address.id => "new_value"
                  }
                ) 
                subject.update_embedded(proxy_for_person, "new_value")
              end

              it "asks row to be saved" do
                row.should_receive(:save)
                subject.update_embedded(proxy_for_person, "new_value")
              end
            end
          end



        end
      end
    end
  end
end


