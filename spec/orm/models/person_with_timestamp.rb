class PersonWithTimestamp < MassiveRecord::ORM::Table
  column_family :info do
    field :name
    field :email
    field :age, :integer
    field :points, :integer, :default => 1, :column => :pts
    field :date_of_birth, :date
    field :status, :boolean, :default => false
    field :addresses, :hash, :default => {}

    field :created_at, :time
  end

  private

  def default_id
    next_id
  end
end
