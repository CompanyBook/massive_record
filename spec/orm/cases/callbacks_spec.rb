require 'spec_helper'
require 'orm/models/callback_testable'
require 'orm/models/person'
require 'orm/models/address'

describe "callbacks on" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  class CallbackDeveloperTable < MassiveRecord::ORM::Table
    include CallbackTestable

    embeds_many :callback_developer_embeddeds, :store_in => :base

    column_family :base do
      field :name, :default => "Thorbjorn"
    end
  end

  describe CallbackDeveloperTable do
    let(:new_record) { described_class.new "1" }
    let(:created_record) { described_class.create "dummy" }
    let(:persisted_record) do
      described_class.create! "1"
      described_class.find "1"
    end

    it_should_behave_like "a model with callbacks"
  end




  class CallbackDeveloperEmbedded < MassiveRecord::ORM::Embedded
    include CallbackTestable

    embedded_in :callback_developer_table

    field :name, :default => "Trym"
  end

  describe CallbackDeveloperEmbedded do
    let(:owner_new_record) {  CallbackDeveloperTable.new "1" }
    let(:owner) { owner_new_record.save! ; owner_new_record }

    let(:new_record) { described_class.new "1", :callback_developer_table => owner_new_record }
    let(:created_record) { described_class.create "dummy", :callback_developer_table => owner_new_record }
    let(:persisted_record) do
      owner.callback_developer_embeddeds << described_class.new("1-1")
      owner.callback_developer_embeddeds.reset # Resets to drop all proxy cached records, force reload from DB
      owner.callback_developer_embeddeds.find("1-1")
    end

    it_should_behave_like "a model with callbacks"


    describe "saved via owner" do
      context "when owner is new record" do
        subject { new_record }
        before { subject } # Tap to initialize

        describe "save callbacks" do
          it "runs in correct order" do
            owner_new_record.save
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
      end

      context "when owner is persisted" do
        subject { persisted_record; owner.callback_developer_embeddeds.first }
        before { subject } # Tap to initialize

        describe "update callbacks" do
          it "is run in correct order" do
            subject.name += "_NEW"
            subject.history.clear
            owner.save
            subject.history.should eq [
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
      end
    end
  end
end

