module MassiveRecord
  module ORM
    module Schema
      class InvalidField < ArgumentError; end

      class Fields < Set
        attr_accessor :contained_in

        def add(field)
          field.fields = self
          raise InvalidField.new(field.errors.full_messages.join(". ")) unless field.valid?
          super
        end
        alias_method :<<, :add

        def field_by_name(name)
          name = name.to_s
          detect { |field| field.name == name }
        end

        def attribute_name_taken?(name, check_only_self = false)
          name = name.to_s
          check_only_self || contained_in.nil? ? attribute_names.include?(name) : contained_in.attribute_name_taken?(name) 
        end


        def to_hash
          Hash[collect { |field| [field.name, field] }]
        end

        def attribute_names
          to_hash.keys
        end
      end
    end
  end
end
