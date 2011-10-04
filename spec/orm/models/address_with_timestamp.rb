class AddressWithTimestamp < MassiveRecord::ORM::Embedded
  embedded_in :person, :inverse_of => :addresses_with_timestamp
  embedded_in :addressable, :inverse_of => :addresses, :polymorphic => true

  field :street
  field :number, :integer
  field :nice_place, :boolean, :default => true
  field :zip, :column => :postal_code
  timestamps

  validates_presence_of :street
end
