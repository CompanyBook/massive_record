require 'spec_helper'
require 'orm/models/test_class'

describe MassiveRecord::ORM::Persistence::Operations do
  let(:record) { TestClass.new }
  let(:options) { {:this => 'hash', :has => 'options'} }

  describe "factory method" do
    [:insert, :update, :destroy].each do |method|
      describe "##{method}" do
        subject { described_class.send(method, record, options) }

        its(:record) { should eq record }
        its(:klass) { should eq TestClass }
        its(:options) { should eq options }
      end
    end
  end
end
