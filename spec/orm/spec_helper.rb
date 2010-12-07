Rspec.configure do |config|
  config.before(:each) do
    mock_connection = mock(MassiveRecord::Wrapper::Connection, :open => true)
    MassiveRecord::Wrapper::Connection.stub(:new).and_return(mock_connection)
    MassiveRecord::ORM::Base.connection_configuration = {:host => "foo", :port => 9001}
  end

  config.after(:each) do
    MassiveRecord::ORM::Base.reset_connection!
  end
end
