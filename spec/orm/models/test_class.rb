class TestClass < MassiveRecord::ORM::Table
  column_family :test_family do
    field :foo, :string
  end
end
