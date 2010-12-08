require 'spec_helper'

describe "connection" do
  
  describe "a new connection" do
    
    before do
      @connection ||= MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
    end
    
  end
  
end
