# Thrift Gems
require 'thrift'
require 'thrift/transport/socket'
require 'thrift/protocol/binary_protocol'

# Generated Ruby classes from Thrift for HBase
require 'massive_record/thrift/hbase_constants'
require 'massive_record/thrift/hbase_types'
require 'massive_record/thrift/hbase'

# HBase connection
require 'massive_record/base'
require 'massive_record/connection'
require 'massive_record/migration'

# HBase classes
require 'massive_record/table'
require 'massive_record/row'
require 'massive_record/column_families_collection'
require 'massive_record/column_family'
require 'massive_record/column'
require 'massive_record/cell'
require 'massive_record/scanner'