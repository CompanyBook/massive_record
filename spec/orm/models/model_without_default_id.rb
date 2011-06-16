class ModelWithoutDefaultId < MassiveRecord::ORM::Table
  column_family :info do
    field :description, :default => "I don't have any ID", :allow_nil => false
  end
end
