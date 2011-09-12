class Address < MassiveRecord::ORM::Embedded
  field :street
  field :number, :integer
  field :nice_place, :boolean, :default => true

  validates_presence_of :street
end
