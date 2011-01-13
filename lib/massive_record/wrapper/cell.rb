module MassiveRecord
  module Wrapper
    class Cell
      attr_writer :value
      attr_accessor :created_at

      class << self
        def serialize_value(v)
          serialize?(v) ? v.to_yaml : v.to_s
        end

        private

        def serialize?(v)
          [Hash, Array, NilClass].include?(v.class)
        end
      end

      def initialize(opts = {})
        @value = opts[:value]
        @created_at = opts[:created_at]
      end
    
      def value
        @value.is_a?(String) ? @value.to_s.force_encoding(Encoding::UTF_8) : @value
      end
    
      def deserialize_value
        is_yaml? ? YAML.load(@value) : @value
      end
    
      def serialize_value(v)
        @value = self.class.serialize_value(v)
      end
    
      def serialized_value
        self.class.serialize_value(@value)
      end
    
      def is_yaml?
        @value =~ /^--- \n/ || @value =~ /^--- {}/ || @value =~ /^--- \[\]/
      end
    end
  end
end
