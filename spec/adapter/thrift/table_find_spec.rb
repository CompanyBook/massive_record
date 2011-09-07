require 'spec_helper'

describe MassiveRecord::Adapters::Thrift::Table do
  let(:connection) do
    MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port']).tap do |connection|
      connection.open
    end
  end

  subject do
    MassiveRecord::Wrapper::Table.new(connection, MR_CONFIG['table'])
  end


  before :all do
    subject.column_families.create(:base)
    subject.save
  end
  
  after :all do
    subject.destroy
  end

  

  before do
    2.times do |index|
      MassiveRecord::Wrapper::Row.new.tap do |row|
        row.id = (index + 1).to_s
        row.values = {:base => {:first_name => "John-#{index}", :last_name => "Doe-#{index}" }}
        row.table = subject
        row.save
      end
    end
  end

  after do
    subject.all.each &:destroy
  end

  it "finds one id" do
    subject.find("1").id.should eq "1"
  end

  it "finds one id given as array" do
    subject.find(["1"]).first.id.should eq "1"
  end

  it "finds multiple ids" do
    subject.find(["1", "2"]).collect(&:id).should eq ["1", "2"]
  end
end
