#
# Set up mock MassiveRecord connection to speed things up and
# skip the actual database when it's not needed.
#
module MockMassiveRecordConnection
  extend ActiveSupport::Concern

  included do
    before do
      #
      # The following is needed to make all READ from the DB to go through
      #

      # Setting up expected connection configuration, or else an error will be raised
      MassiveRecord::ORM::Base.connection_configuration = {:host => "foo", :port => 9001}

      # Setting up a mock connection when asked for new
      mock_connection = mock(MassiveRecord::Wrapper::Connection, :open => true)
      MassiveRecord::Wrapper::Connection.stub(:new).and_return(mock_connection)

      # Inject find method on tables so that we don't need to go through with
      # the actual call to the database.
      new_table_method = MassiveRecord::Wrapper::Table.method(:new)
      MassiveRecord::Wrapper::Table.stub!(:new) do |*args|
        table = new_table_method.call(*args)
        # Defines a dummy find method which simply returns a hash where id is set to the first
        # argument (Like Person.find(1)).
        def table.find(*args)
          row = MassiveRecord::Wrapper::Row.new
          row.id = args[0]
          row.values = {}
          row
        end
        table
      end

      #
      # The following is needed to make all WRITE to the DB to go through
      #
      # ..as you see, nothing is here yet ;)
    end




    after do
      MassiveRecord::ORM::Base.descendants.each { |klass| klass.unmemoize_all }
      MassiveRecord::ORM::Base.reset_connection!
    end
  end
end
