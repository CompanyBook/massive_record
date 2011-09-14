require 'spec_helper'

class TestEmbedsManyProxy < MassiveRecord::ORM::Relations::Proxy::EmbedsMany; end

describe TestEmbedsManyProxy do
  include SetUpHbaseConnectionBeforeAll 
  include SetTableNamesToTestTable

  let(:proxy_owner) { Person.new "person-id-1", :name => "Test", :age => 29 }
  let(:proxy_target) { Address.new "address-1", :street => "Asker", :number => 1 }
  let(:proxy_target_2) { Address.new "address-2", :street => "Asker", :number => 2 }
  let(:proxy_target_3) { Address.new "address-3", :street => "Asker", :number => 3 }
  let(:metadata) { subject.metadata }

  let(:raw_data) do
    {
      proxy_target.id => proxy_target.attributes_db_raw_data_hash,
      proxy_target_2.id => proxy_target_2.attributes_db_raw_data_hash,
      proxy_target_3.id => proxy_target_3.attributes_db_raw_data_hash,
    }
  end


  subject { proxy_owner.send(:relation_proxy, 'addresses') }


  it_should_behave_like "relation proxy"



  describe "#proxy_targets_raw" do
    it "is a hash" do
      subject.proxy_targets_raw.should be_instance_of Hash
    end

    context "proxy owner is new record" do
      its(:proxy_targets_raw) { should be_empty }
    end

    context "proxy owner is saved and has records" do
      before do
        proxy_owner.instance_variable_set(:@raw_data, {'addresses' => raw_data})
      end

      it "includes raw data from database" do
        subject.proxy_targets_raw.should eq raw_data
      end
    end
  end

  describe "#reload" do
    it "reloads its's column family and replaces raw data" do
      pending
    end
  end



  describe "adding records to collection" do
    [:<<, :push, :concat].each do |add_method|
      describe "by ##{add_method}" do
        it "includes added record in proxy target" do
          subject.send add_method, proxy_target
          subject.proxy_target.should include proxy_target
        end

        it "does not accept invalid records" do
          proxy_target.should_receive(:valid?).and_return false
          subject.send(add_method, proxy_target).should be_false
          subject.should be_empty
        end

        it "returns self so you can chain calls" do
          subject.send(add_method, proxy_target).send(add_method, proxy_target_2)
          subject.proxy_target.should include proxy_target, proxy_target_2
        end

        it "saves proxy owner if it is already persisted" do
          proxy_owner.should_receive(:persisted?).and_return true
          proxy_owner.should_receive(:save).once
          subject.send add_method, proxy_target
        end

        it "marks added records as persisted" do
          proxy_owner.should_receive(:persisted?).and_return true
          proxy_owner.should_receive(:save).once
          subject.send add_method, proxy_target
        end

        it "does not save proxy owner if it is a new record" do
          pending "Actually saving is not yet completed.."
          subject.send add_method, proxy_target
          proxy_target.should be_persisted
        end

        it "does not add existing records" do
          2.times { subject.send add_method, proxy_target }
          subject.proxy_target.length.should eq 1
        end
      end
    end
  end


  describe "#can_find_proxy_target?" do
    it "is false when we have no raw targets in owner" do
      subject.should_not be_can_find_proxy_target
    end

    it "is true when we have some raw targets" do
      proxy_owner.instance_variable_set(:@raw_data, {'addresses' => raw_data})
      subject.should be_can_find_proxy_target
    end
  end



  describe "#load_proxy_target" do
    context "empty proxy targets raw" do
      before { proxy_owner.instance_variable_set(:@raw_data, {'addresses' => {}}) }

      its(:load_proxy_target) { should eq [] }

      it "includes added records to collection" do
        subject << proxy_target
        subject.load_proxy_target.should include proxy_target
      end
    end

    context "filled proxy_targets_raw" do
      before { proxy_owner.instance_variable_set(:@raw_data, {'addresses' => raw_data}) }

      its(:load_proxy_target) { should include proxy_target, proxy_target_2, proxy_target_3 }
    end
  end



  describe "#proxy_targets_update_hash" do
    before do
      proxy_owner.save!
    end

    context "no changes" do
      before do
        subject << proxy_target
        proxy_target.should_receive(:destroyed?).and_return false
        proxy_target.should_receive(:new_record?).and_return false
        proxy_target.should_receive(:changed?).and_return false
      end

      its(:proxy_targets_update_hash) { should be_empty }
    end

    context "insert" do
      before do
        subject << proxy_target
        proxy_target.should_receive(:destroyed?).and_return false
        proxy_target.should_receive(:new_record?).and_return true
        proxy_target.should_not_receive(:changed?)
      end

      it "includes id for record to be inserted" do
        subject.proxy_targets_update_hash.keys.should eq [proxy_target.id]
      end

      it "includes attributes for record to be inserted" do
        subject.proxy_targets_update_hash.values.should eq [proxy_target.attributes_db_raw_data_hash]
      end
    end

    context "update" do
      before do
        subject << proxy_target
        proxy_target.should_receive(:destroyed?).and_return false
        proxy_target.should_receive(:new_record?).and_return false
        proxy_target.should_receive(:changed?).and_return true
      end

      it "includes id for record to be updated" do
        subject.proxy_targets_update_hash.keys.should eq [proxy_target.id]
      end

      it "includes attributes for record to be updated" do
        subject.proxy_targets_update_hash.values.should eq [proxy_target.attributes_db_raw_data_hash]
      end
    end

    context "destroy" do
      before do
        subject << proxy_target
        proxy_target.should_receive(:destroyed?).and_return true
        proxy_target.should_not_receive(:new_record?).and_return false
        proxy_target.should_not_receive(:changed?).and_return false
      end

      it "includes id for record to be updated" do
        subject.proxy_targets_update_hash.keys.should eq [proxy_target.id]
      end

      it "includes attributes for record to be updated" do
        subject.proxy_targets_update_hash.values.should eq [nil]
      end
    end
  end

  describe "#changed?" do
    before do
      subject << proxy_target
      proxy_target.stub(:destroyed?).and_return false
      proxy_target.stub(:new_record?).and_return false
      proxy_target.stub(:changed?).and_return false
    end

    it "returns false if no changes has been made which needs persistence" do
      should_not be_changed
    end

    it "returns true if it contains new records" do
      proxy_target.should_receive(:new_record?).and_return true
      should be_changed
    end

    it "returns true if it contains destroyed records" do
      proxy_target.should_receive(:destroyed?).and_return true
      should be_changed
    end

    it "returns true if it contains changed records" do
      proxy_target.should_receive(:changed?).and_return true
      should be_changed
    end
  end
end
