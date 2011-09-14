class Address < MassiveRecord::ORM::Embedded
  field :street
  field :number, :integer
  field :nice_place, :boolean, :default => true
  field :zip, :column => :postal_code

  validates_presence_of :street
end
