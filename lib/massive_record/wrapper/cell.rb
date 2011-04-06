module MassiveRecord
  module Wrapper
    class Cell
      attr_reader :value
      attr_accessor :created_at

      def initialize(opts = {})
        self.value = opts[:value]
        self.created_at = opts[:created_at]
      end
    
      def value=(v)
        raise "#{v} was a #{v.class}, but it must be a String!" unless v.is_a? String
        @value = v.dup.force_encoding(Encoding::UTF_8)
      end

      def value_to_thrift
        value.force_encoding(Encoding::BINARY)
      end
    end
  end
end
