class TestClass < MassiveRecord::ORM::Table
  
  references_one :attachable, :polymorphic => true, :store_in => :test_family

  column_family :test_family do
    field :foo, :string
  end
end
