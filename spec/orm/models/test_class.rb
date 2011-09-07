class TestClass < MassiveRecord::ORM::Table
  
  references_one :attachable, :polymorphic => true, :store_in => :test_family

  column_family :test_family do
    field :foo, :string
    field :hash_not_allow_nil, :hash, :allow_nil => false
    field :tested_at, :time
  end
end
