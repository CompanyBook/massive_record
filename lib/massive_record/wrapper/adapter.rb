module MassiveRecord
  def self.adapter=(name)
    @adapter = name
  end
  
  def self.adapter
    @adapter
  end
end

# Default adapter is set to thrift
MassiveRecord.adapter = :thrift

# Check the adapter is valid
raise "The adapter can only be 'thrift'." unless ['thrift'].include?(MassiveRecord.adapter.to_s)

# Load specific adapter
require "massive_record/adapters/#{MassiveRecord.adapter}/adapter"

# Include the specific Adapters classes into the Wrapper
module MassiveRecord
  module Wrapper
    include ADAPTER
  end
end