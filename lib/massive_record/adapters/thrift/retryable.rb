require 'massive_record/wrapper/retryable'

module MassiveRecord
  module Adapters
    module Thrift
      class Retryable < MassiveRecord::Wrapper::Retryable

        def initialize(opts = {}, &block)
          opts[:on] ||= ::Apache::Hadoop::Hbase::Thrift::IOError
          super
        end

      end
    end
  end
end