require 'set'

module MassiveRecord
  module ORM
    module Schema
      class ColumnFamilies < Set
        def add(family)
          super
          family.column_families = self
        end
        alias_method :<<, :add
      end
    end
  end
end
