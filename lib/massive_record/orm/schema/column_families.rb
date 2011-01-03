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


        def family_by_name(name)
          detect { |family| family.name == name.to_s }
        end

        def family_by_name_or_new(name)
          unless known_family = family_by_name(name)
            known_family = ColumnFamily.new(:name => name)
            add(known_family)
          end
          known_family
        end


        def to_hash
          inject({}) do |hash, column_family|
            hash.update(column_family.to_hash)
            hash
          end
        end

        def attribute_names
          to_hash.keys
        end


        def attribute_name_taken?(name)
          attribute_names.include? name.to_s
        end
      end
    end
  end
end
