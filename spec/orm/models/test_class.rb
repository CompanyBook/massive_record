class TestClass < MassiveRecord::ORM::Table
  column_family :info do
    field :foo, :string
  end
end
