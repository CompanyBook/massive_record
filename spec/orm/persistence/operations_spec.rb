require 'spec_helper'
require 'orm/models/test_class'

describe MassiveRecord::ORM::Persistence::Operations do
  let(:options) { {:this => 'hash', :has => 'options'} }

  describe "factory method" do
    context "table record" do
      let(:record) { TestClass.new }

      [:insert, :update, :destroy, :atomic_operation].each do |method|
        describe "##{method}" do
          subject { described_class.send(method, record, options) }

          its(:record) { should eq record }
          its(:klass) { should eq record.class }
          its(:options) { should eq options }

          it "is an instance of Persistence::Operations::#{method.to_s.classify}" do
            klass = "MassiveRecord::ORM::Persistence::Operations::#{method.to_s.classify}".constantize
            should be_instance_of klass
          end

          it "is possible to suppress" do
             MassiveRecord::ORM::Persistence::Operations.suppress do
               subject.should be_instance_of MassiveRecord::ORM::Persistence::Operations::Suppress
             end
          end
        end
      end
    end

    context "embedded record" do
      let(:record) { Address.new }

      [:insert, :update, :destroy].each do |method|
        describe "##{method}" do
          subject { described_class.send(method, record, options) }

          its(:record) { should eq record }
          its(:klass) { should eq record.class }
          its(:options) { should eq options }

          it "is an instance of Persistence::Operations::#{method.to_s.classify}" do
            klass = "MassiveRecord::ORM::Persistence::Operations::Embedded::#{method.to_s.classify}".constantize
            should be_instance_of klass
          end

          it "is possible to suppress" do
             MassiveRecord::ORM::Persistence::Operations.suppress do
               subject.should be_instance_of MassiveRecord::ORM::Persistence::Operations::Suppress
             end
          end
        end
      end
    end
  end
end
