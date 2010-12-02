# Thrift Gems
require 'thrift'
require 'thrift/transport/socket'
require 'thrift/protocol/binary_protocol'

# Generated Ruby classes from Thrift for HBase
require 'massive_record/thrift/hbase_constants'
require 'massive_record/thrift/hbase_types'
require 'massive_record/thrift/hbase'

# Wrapper
require 'massive_record/wrapper/base'

# ORM
require 'massive_record/orm/base'