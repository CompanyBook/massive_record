class Address < MassiveRecord::ORM::Column
  field :street
  field :number, :integer
  field :nice_place, :boolean, :default => true

  validates_presence_of :street
end
