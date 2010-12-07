Rspec.configure do |config|
  config.before(:each) do
    MassiveRecord::ORM::Base.connection_configuration = {:host => "foo", :port => 9001}
  end

  config.after(:each) do
    MassiveRecord::ORM::Base.reset_connection!
  end
end
