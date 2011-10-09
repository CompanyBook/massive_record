require 'spec_helper'
require 'orm/models/callback_testable'
require 'orm/models/person'
require 'orm/models/address'

describe "callbacks" do
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
    let(:owner) { CallbackDeveloperTable.create! "1" }

    let(:created_record) { described_class.create "dummy", :callback_developer_table => owner }
    let(:persisted_record) do
      owner.callback_developer_embeddeds << described_class.new("1-1")
      owner.callback_developer_embeddeds.find("1-1")
    end

    it_should_behave_like "a model with callbacks"
  end
end

