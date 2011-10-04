class Car < MassiveRecord::ORM::Embedded
  embedded_in :person

  field :color
end
