module MassiveRecord
  module Wrapper
    include MassiveRecord::Adapters::Thrift::Connection
  end
end