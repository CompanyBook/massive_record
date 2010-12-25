module MassiveRecord
  module ORM
    module Schema
      class InvalidField < ArgumentError; end

      class Fields < Set
        def add(field)
          field.fields = self
          raise InvalidField.new(field.errors.full_messages.join(". ")) unless field.valid?
          super
        end
        alias_method :<<, :add


        def to_hash
          inject({}) do |hash, field|
            hash[field.name] = field
            hash
          end
        end

        def attribute_names
          to_hash.keys
        end
      end
    end
  end
end
