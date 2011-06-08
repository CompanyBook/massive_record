class Person < MassiveRecord::ORM::Table
  column_family :info do
    field :name
    field :email
    field :age, :integer
    field :date_of_birth, :date
    field :addresses, :hash, :default => {}
    field :type
  end

  column_family :base do
    field :points, :integer, :default => 1, :column => :pts
    field :status, :boolean, :default => false
    field :phone_numbers, :array, :allow_nil => false
  end


  references_one :boss, :class_name => "PersonWithTimestamp", :store_in => :info
  references_many :test_classes, :store_in => :info
  references_many :friends, :class_name => "Person", :records_starts_from => :friends_records_starts_from_id

  validates_presence_of :name, :age
  validates_numericality_of :age, :greater_than_or_equal_to => 0
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true


  def friends_records_starts_from_id
    id+'-'
  end
end
