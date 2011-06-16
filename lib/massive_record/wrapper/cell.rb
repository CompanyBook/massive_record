module MassiveRecord
  module Wrapper
    class Cell
      SUPPORTED_TYPES = [NilClass, String, Fixnum, Bignum]

      attr_reader :value
      attr_accessor :created_at


      #
      # Packs an integer as a 64-bit signed integer, native endian (int64_t)
      # Reverse it as the byte order in hbase are reversed
      #
      def self.integer_to_hex_string(int)
        [int].pack('q').reverse
      end

      #
      # Unpacks an string as a 64-bit signed integer, native endian (int64_t)
      # Reverse it before unpack as the byte order in hbase are reversed
      #
      def self.hex_string_to_integer(string)
        string.reverse.unpack("q*").first
      end



      def initialize(opts = {})
        self.value = opts[:value]
        self.created_at = opts[:created_at]
      end
    
      def value=(v)
        raise "#{v} was a #{v.class}, but it must be a one of: #{SUPPORTED_TYPES.join(', ')}" unless SUPPORTED_TYPES.include? v.class

        @value = v.duplicable? ? v.dup : v
      end

      def value_to_thrift
        case value
        when String
          value.force_encoding(Encoding::BINARY)
        when Fixnum, Bignum
          self.class.integer_to_hex_string(value)
        when NilClass
          value
        end
      end
    end
  end
end
