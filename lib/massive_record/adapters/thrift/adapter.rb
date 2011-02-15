module MassiveRecord
  module Adapters
    module Thrift
    end
  end
end

ADAPTER = MassiveRecord::Adapters::Thrift

# Thrift Gems
require 'thrift'
require 'thrift/transport/socket'
require 'thrift/protocol/binary_protocol'

# Generated Ruby classes from Thrift for HBase
require 'massive_record/adapters/thrift/hbase/hbase_constants'
require 'massive_record/adapters/thrift/hbase/hbase_types'
require 'massive_record/adapters/thrift/hbase/hbase'

# Adapter
require 'massive_record/adapters/thrift/column_family'
require 'massive_record/adapters/thrift/connection'
require 'massive_record/adapters/thrift/row'
require 'massive_record/adapters/thrift/scanner'
require 'massive_record/adapters/thrift/table'