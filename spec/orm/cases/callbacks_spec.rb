require 'spec_helper'
require 'orm/models/callback_testable'
require 'orm/models/person'
require 'orm/models/address'

describe "callbacks" do
  include SetUpHbaseConnectionBeforeAll
  include SetTableNamesToTestTable

  class CallbackDeveloperTable < MassiveRecord::ORM::Table
    include CallbackTestable

    column_family :base do
      field :name, :default => "Thorbjorn"
    end
  end

  describe CallbackDeveloperTable do
    it_should_behave_like "a model with callbacks"
  end
end

