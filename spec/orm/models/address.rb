class Address < MassiveRecord::ORM::Column
  validates_presence_of :street
end
