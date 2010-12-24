require 'set'

module MassiveRecord
  module ORM
    module Schema
      class InvalidColumnFamily < ArgumentError; end

      class ColumnFamilies < Set
        def add(family)
          family.column_families = self
          raise InvalidColumnFamily.new(family.errors.full_messages.join(". ")) unless family.valid?
          super
        end
        alias_method :<<, :add
      end
    end
  end
end
