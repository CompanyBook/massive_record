#
# Set up mock MassiveRecord connection to speed things up and
# skip the actual database when it's not needed.
#
module MockMassiveRecordConnection
  def self.included(base)
    base.class_eval do
      before do
        mock_connection = mock(MassiveRecord::Wrapper::Connection, :open => true)
        MassiveRecord::Wrapper::Connection.stub(:new).and_return(mock_connection)
        MassiveRecord::ORM::Base.connection_configuration = {:host => "foo", :port => 9001}
      end

      after do
        MassiveRecord::ORM::Base.reset_connection!
      end
    end
  end
end
