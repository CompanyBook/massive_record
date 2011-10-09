require 'spec_helper'

shared_examples_for "a model with callbacks" do
  include MockMassiveRecordConnection

  describe "initialize callbacks" do
    it "runs in correct order" do
      subject.history.should eq [
        [:after_initialize, :method],
        [:after_initialize, :string],
        [:after_initialize, :proc],
        [:after_initialize, :object],
        [:after_initialize, :block]
      ]
    end
  end

  describe "find callbacks" do
    subject { described_class.find(1) }
      
    it "runs in correct order" do
      subject.history.should eq [
        [:after_find, :method],
        [:after_find, :string],
        [:after_find, :proc],
        [:after_find, :object],
        [:after_find, :block],
        [:after_initialize, :method],
        [:after_initialize, :string],
        [:after_initialize, :proc],
        [:after_initialize, :object],
        [:after_initialize, :block]
      ]
    end
  end


  describe "touch callbacks" do
    it "runs in correct order" do
      subject.history.clear
      subject.touch
      subject.history.should eq [
        [:after_touch, :method],
        [:after_touch, :string],
        [:after_touch, :proc],
        [:after_touch, :object],
        [:after_touch, :block]
      ]
    end
  end



  describe "validations callback" do
    it "runs in correct order for new records" do
      subject.valid?
      subject.history.should eq [
        [:after_initialize, :method],
        [:after_initialize, :string],
        [:after_initialize, :proc],
        [:after_initialize, :object],
        [:after_initialize, :block],
        [:before_validation, :method],
        [:before_validation, :string],
        [:before_validation, :proc],
        [:before_validation, :object],
        [:before_validation, :block],
        [:after_validation, :method],
        [:after_validation, :string],
        [:after_validation, :proc],
        [:after_validation, :object],
        [:after_validation, :block]
      ]
    end

    it "runs in correct order for persisted records" do
      subject = described_class.find(1)
      subject.valid?
      subject.history.should eq [
        [:after_find, :method],
        [:after_find, :string],
        [:after_find, :proc],
        [:after_find, :object],
        [:after_find, :block],
        [:after_initialize, :method],
        [:after_initialize, :string],
        [:after_initialize, :proc],
        [:after_initialize, :object],
        [:after_initialize, :block],
        [:before_validation, :method],
        [:before_validation, :string],
        [:before_validation, :proc],
        [:before_validation, :object],
        [:before_validation, :block],
        [:after_validation, :method],
        [:after_validation, :string],
        [:after_validation, :proc],
        [:after_validation, :object],
        [:after_validation, :block]
      ]
    end
  end


  describe "create callbacks" do
    subject { described_class.create "dummy" }

    it "runs in correct order" do
      subject.history.should eq [
        [:after_initialize, :method],
        [:after_initialize, :string],
        [:after_initialize, :proc  ],
        [:after_initialize, :object],
        [:after_initialize, :block ],
        [:before_validation, :method],
        [:before_validation, :string],
        [:before_validation, :proc  ],
        [:before_validation, :object],
        [:before_validation, :block ],
        [:after_validation, :method],
        [:after_validation, :string],
        [:after_validation, :proc  ],
        [:after_validation, :object],
        [:after_validation, :block ],
        [:before_save, :method],
        [:before_save, :string],
        [:before_save, :proc  ],
        [:before_save, :object],
        [:before_save, :block ],
        [:before_create, :method],
        [:before_create, :string],
        [:before_create, :proc  ],
        [:before_create, :object],
        [:before_create, :block ],
        [:after_create, :method],
        [:after_create, :string],
        [:after_create, :proc  ],
        [:after_create, :object],
        [:after_create, :block ],
        [:after_save, :method],
        [:after_save, :string],
        [:after_save, :proc  ],
        [:after_save, :object],
        [:after_save, :block ]
      ]
    end
  end


  describe "update callbacks" do
    subject { described_class.find(1) }

    it "runs in the correct order" do
      subject.save
      subject.history.should eq [
        [:after_find, :method],
        [:after_find, :string],
        [:after_find, :proc],
        [:after_find, :object],
        [:after_find, :block],
        [:after_initialize, :method],
        [:after_initialize, :string],
        [:after_initialize, :proc  ],
        [:after_initialize, :object],
        [:after_initialize, :block ],
        [:before_validation, :method],
        [:before_validation, :string],
        [:before_validation, :proc  ],
        [:before_validation, :object],
        [:before_validation, :block ],
        [:after_validation, :method],
        [:after_validation, :string],
        [:after_validation, :proc  ],
        [:after_validation, :object],
        [:after_validation, :block ],
        [:before_save, :method],
        [:before_save, :string],
        [:before_save, :proc  ],
        [:before_save, :object],
        [:before_save, :block ],
        [:before_update, :method],
        [:before_update, :string],
        [:before_update, :proc  ],
        [:before_update, :object],
        [:before_update, :block ],
        [:after_update, :method],
        [:after_update, :string],
        [:after_update, :proc  ],
        [:after_update, :object],
        [:after_update, :block ],
        [:after_save, :method],
        [:after_save, :string],
        [:after_save, :proc  ],
        [:after_save, :object],
        [:after_save, :block ]
      ]
    end
  end


  describe "destroy callbacks" do
    subject { described_class.find(1) }

    it "runs in correct order" do
      subject.destroy
      subject.history.should eq [
        [:after_find, :method],
        [:after_find, :string],
        [:after_find, :proc],
        [:after_find, :object],
        [:after_find, :block],
        [:after_initialize, :method],
        [:after_initialize, :string],
        [:after_initialize, :proc  ],
        [:after_initialize, :object],
        [:after_initialize, :block ],
        [:before_destroy, :method],
        [:before_destroy, :string],
        [:before_destroy, :proc  ],
        [:before_destroy, :object],
        [:before_destroy, :block ],
        [:after_destroy, :method],
        [:after_destroy, :string],
        [:after_destroy, :proc  ],
        [:after_destroy, :object],
        [:after_destroy, :block ]
      ]
    end
  end



  describe "delete callbacks" do
    subject { described_class.find(1) }

    it "does not run callbacks for destroy" do
      subject.delete
      subject.should be_destroyed
      subject.history.should eq [
        [:after_find, :method],
        [:after_find, :string],
        [:after_find, :proc],
        [:after_find, :object],
        [:after_find, :block],
        [:after_initialize, :method],
        [:after_initialize, :string],
        [:after_initialize, :proc  ],
        [:after_initialize, :object],
        [:after_initialize, :block ]
      ]
    end
  end
end
