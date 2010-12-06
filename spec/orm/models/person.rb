class Person < MassiveRecord::ORM::Table
  validates_presence_of :name, :email, :age
  validates_numericality_of :age, :greater_than_or_equal_to => 0
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  column_family :info do
    field :first_name
    field :last_name
    field :email
    field :age, Integer, :default => 0
    field :date_of_birth, Date
    field :status, Boolean, :default => false
  end
  
  #def name
    #"#{first_name} #{last_name}"
  #end
  
  #def active?
    #status == 1
  #end
end
