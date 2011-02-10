module MassiveRecord
  module Wrapper
    include MassiveRecord::Adapters::Thrift::ColumnFamily
  end
end