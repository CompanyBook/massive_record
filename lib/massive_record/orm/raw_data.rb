module MassiveRecord
  module ORM

    #
    # Class to hold one raw data, and some meta data for that value.
    # As of writing this the meta data is when cell which the data
    # originates from was last written to (created_at).
    #
    class RawData
      attr_reader :value, :created_at


      class << self
        def new_with_data_from(object)
          send("new_with_data_from_#{object.class.to_s.demodulize.underscore}", object)
        end


        private

        def new_with_data_from_cell(cell)
          new(value: cell.value, created_at: cell.created_at)
        end
      end



      def initialize(attributes)
        @value = attributes[:value]
        @created_at = attributes[:created_at]
      end



      def inspect
        "<#{self.class} #{value.inspect}>"
      end
      delegate :to_s, :to => :value


      def ==(other)
        other.equal?(self) ||
          other.instance_of?(self.class) && value == other.value && created_at == other.created_at
      end
      alias_method :eql?, :==

      def hash
        [id, created_at].hash
      end
    end
  end
end
