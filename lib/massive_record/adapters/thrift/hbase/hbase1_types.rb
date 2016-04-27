#
# Autogenerated by Thrift Compiler (0.9.3)
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#

require 'thrift'

module Apache
  module Hadoop
    module Hbase
      module Thrift
        # TCell - Used to transport a cell value (byte[]) and the timestamp it was
# stored with together as a result for get and getRow methods. This promotes
# the timestamp of a cell to a first-class value, making it easy to take
# note of temporal data. Cell is used all the way from HStore up to HTable.
        class TCell
          include ::Thrift::Struct, ::Thrift::Struct_Union
          VALUE = 1
          TIMESTAMP = 2

          FIELDS = {
            VALUE => {:type => ::Thrift::Types::STRING, :name => 'value', :binary => true},
            TIMESTAMP => {:type => ::Thrift::Types::I64, :name => 'timestamp'}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # An HColumnDescriptor contains information about a column family
# such as the number of versions, compression settings, etc. It is
# used as input when creating a table or adding a column.
        class ColumnDescriptor
          include ::Thrift::Struct, ::Thrift::Struct_Union
          NAME = 1
          MAXVERSIONS = 2
          COMPRESSION = 3
          INMEMORY = 4
          BLOOMFILTERTYPE = 5
          BLOOMFILTERVECTORSIZE = 6
          BLOOMFILTERNBHASHES = 7
          BLOCKCACHEENABLED = 8
          TIMETOLIVE = 9

          FIELDS = {
            NAME => {:type => ::Thrift::Types::STRING, :name => 'name', :binary => true},
            MAXVERSIONS => {:type => ::Thrift::Types::I32, :name => 'maxVersions', :default => 3},
            COMPRESSION => {:type => ::Thrift::Types::STRING, :name => 'compression', :default => %q"NONE"},
            INMEMORY => {:type => ::Thrift::Types::BOOL, :name => 'inMemory', :default => false},
            BLOOMFILTERTYPE => {:type => ::Thrift::Types::STRING, :name => 'bloomFilterType', :default => %q"NONE"},
            BLOOMFILTERVECTORSIZE => {:type => ::Thrift::Types::I32, :name => 'bloomFilterVectorSize', :default => 0},
            BLOOMFILTERNBHASHES => {:type => ::Thrift::Types::I32, :name => 'bloomFilterNbHashes', :default => 0},
            BLOCKCACHEENABLED => {:type => ::Thrift::Types::BOOL, :name => 'blockCacheEnabled', :default => false},
            TIMETOLIVE => {:type => ::Thrift::Types::I32, :name => 'timeToLive', :default => 2147483647}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # A TRegionInfo contains information about an HTable region.
        class TRegionInfo
          include ::Thrift::Struct, ::Thrift::Struct_Union
          STARTKEY = 1
          ENDKEY = 2
          ID = 3
          NAME = 4
          VERSION = 5
          SERVERNAME = 6
          PORT = 7

          FIELDS = {
            STARTKEY => {:type => ::Thrift::Types::STRING, :name => 'startKey', :binary => true},
            ENDKEY => {:type => ::Thrift::Types::STRING, :name => 'endKey', :binary => true},
            ID => {:type => ::Thrift::Types::I64, :name => 'id'},
            NAME => {:type => ::Thrift::Types::STRING, :name => 'name', :binary => true},
            VERSION => {:type => ::Thrift::Types::BYTE, :name => 'version'},
            SERVERNAME => {:type => ::Thrift::Types::STRING, :name => 'serverName', :binary => true},
            PORT => {:type => ::Thrift::Types::I32, :name => 'port'}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # A Mutation object is used to either update or delete a column-value.
        class Mutation
          include ::Thrift::Struct, ::Thrift::Struct_Union
          ISDELETE = 1
          COLUMN = 2
          VALUE = 3
          WRITETOWAL = 4

          FIELDS = {
            ISDELETE => {:type => ::Thrift::Types::BOOL, :name => 'isDelete', :default => false},
            COLUMN => {:type => ::Thrift::Types::STRING, :name => 'column', :binary => true},
            VALUE => {:type => ::Thrift::Types::STRING, :name => 'value', :binary => true},
            WRITETOWAL => {:type => ::Thrift::Types::BOOL, :name => 'writeToWAL', :default => true}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # A BatchMutation object is used to apply a number of Mutations to a single row.
        class BatchMutation
          include ::Thrift::Struct, ::Thrift::Struct_Union
          ROW = 1
          MUTATIONS = 2

          FIELDS = {
            ROW => {:type => ::Thrift::Types::STRING, :name => 'row', :binary => true},
            MUTATIONS => {:type => ::Thrift::Types::LIST, :name => 'mutations', :element => {:type => ::Thrift::Types::STRUCT, :class => ::Apache::Hadoop::Hbase::Thrift::Mutation}}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # For increments that are not incrementColumnValue
# equivalents.
        class TIncrement
          include ::Thrift::Struct, ::Thrift::Struct_Union
          TABLE = 1
          ROW = 2
          COLUMN = 3
          AMMOUNT = 4

          FIELDS = {
            TABLE => {:type => ::Thrift::Types::STRING, :name => 'table', :binary => true},
            ROW => {:type => ::Thrift::Types::STRING, :name => 'row', :binary => true},
            COLUMN => {:type => ::Thrift::Types::STRING, :name => 'column', :binary => true},
            AMMOUNT => {:type => ::Thrift::Types::I64, :name => 'ammount'}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # Holds column name and the cell.
        class TColumn
          include ::Thrift::Struct, ::Thrift::Struct_Union
          COLUMNNAME = 1
          CELL = 2

          FIELDS = {
            COLUMNNAME => {:type => ::Thrift::Types::STRING, :name => 'columnName', :binary => true},
            CELL => {:type => ::Thrift::Types::STRUCT, :name => 'cell', :class => ::Apache::Hadoop::Hbase::Thrift::TCell}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # Holds row name and then a map of columns to cells.
        class TRowResult
          include ::Thrift::Struct, ::Thrift::Struct_Union
          ROW = 1
          COLUMNS = 2
          SORTEDCOLUMNS = 3

          FIELDS = {
            ROW => {:type => ::Thrift::Types::STRING, :name => 'row', :binary => true},
            COLUMNS => {:type => ::Thrift::Types::MAP, :name => 'columns', :key => {:type => ::Thrift::Types::STRING, :binary => true}, :value => {:type => ::Thrift::Types::STRUCT, :class => ::Apache::Hadoop::Hbase::Thrift::TCell}, :optional => true},
            SORTEDCOLUMNS => {:type => ::Thrift::Types::LIST, :name => 'sortedColumns', :element => {:type => ::Thrift::Types::STRUCT, :class => ::Apache::Hadoop::Hbase::Thrift::TColumn}, :optional => true}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # A Scan object is used to specify scanner parameters when opening a scanner.
        class TScan
          include ::Thrift::Struct, ::Thrift::Struct_Union
          STARTROW = 1
          STOPROW = 2
          TIMESTAMP = 3
          COLUMNS = 4
          CACHING = 5
          FILTERSTRING = 6
          BATCHSIZE = 7
          SORTCOLUMNS = 8
          REVERSED = 9

          FIELDS = {
            STARTROW => {:type => ::Thrift::Types::STRING, :name => 'startRow', :binary => true, :optional => true},
            STOPROW => {:type => ::Thrift::Types::STRING, :name => 'stopRow', :binary => true, :optional => true},
            TIMESTAMP => {:type => ::Thrift::Types::I64, :name => 'timestamp', :optional => true},
            COLUMNS => {:type => ::Thrift::Types::LIST, :name => 'columns', :element => {:type => ::Thrift::Types::STRING, :binary => true}, :optional => true},
            CACHING => {:type => ::Thrift::Types::I32, :name => 'caching', :optional => true},
            FILTERSTRING => {:type => ::Thrift::Types::STRING, :name => 'filterString', :binary => true, :optional => true},
            BATCHSIZE => {:type => ::Thrift::Types::I32, :name => 'batchSize', :optional => true},
            SORTCOLUMNS => {:type => ::Thrift::Types::BOOL, :name => 'sortColumns', :optional => true},
            REVERSED => {:type => ::Thrift::Types::BOOL, :name => 'reversed', :optional => true}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # An Append object is used to specify the parameters for performing the append operation.
        class TAppend
          include ::Thrift::Struct, ::Thrift::Struct_Union
          TABLE = 1
          ROW = 2
          COLUMNS = 3
          VALUES = 4

          FIELDS = {
            TABLE => {:type => ::Thrift::Types::STRING, :name => 'table', :binary => true},
            ROW => {:type => ::Thrift::Types::STRING, :name => 'row', :binary => true},
            COLUMNS => {:type => ::Thrift::Types::LIST, :name => 'columns', :element => {:type => ::Thrift::Types::STRING, :binary => true}},
            VALUES => {:type => ::Thrift::Types::LIST, :name => 'values', :element => {:type => ::Thrift::Types::STRING, :binary => true}}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # An IOError exception signals that an error occurred communicating
# to the Hbase master or an Hbase region server.  Also used to return
# more general Hbase error conditions.
        class IOError < ::Thrift::Exception
          include ::Thrift::Struct, ::Thrift::Struct_Union
          def initialize(message=nil)
            super()
            self.message = message
          end

          MESSAGE = 1

          FIELDS = {
            MESSAGE => {:type => ::Thrift::Types::STRING, :name => 'message'}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # An IllegalArgument exception indicates an illegal or invalid
# argument was passed into a procedure.
        class IllegalArgument < ::Thrift::Exception
          include ::Thrift::Struct, ::Thrift::Struct_Union
          def initialize(message=nil)
            super()
            self.message = message
          end

          MESSAGE = 1

          FIELDS = {
            MESSAGE => {:type => ::Thrift::Types::STRING, :name => 'message'}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

        # An AlreadyExists exceptions signals that a table with the specified
# name already exists
        class AlreadyExists < ::Thrift::Exception
          include ::Thrift::Struct, ::Thrift::Struct_Union
          def initialize(message=nil)
            super()
            self.message = message
          end

          MESSAGE = 1

          FIELDS = {
            MESSAGE => {:type => ::Thrift::Types::STRING, :name => 'message'}
          }

          def struct_fields; FIELDS; end

          def validate
          end

          ::Thrift::Struct.generate_accessors self
        end

      end
    end
  end
end
