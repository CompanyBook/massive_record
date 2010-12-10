class Person < MassiveRecord::ORM::Table
  validates_presence_of :name, :age
  validates_numericality_of :age, :greater_than_or_equal_to => 0
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true

  column_family :info do
    field :name
    field :email
    field :age, :integer
    field :points, :integer, :default => 1
    field :date_of_birth, :date
    field :status, :boolean, :default => false
  end
end
