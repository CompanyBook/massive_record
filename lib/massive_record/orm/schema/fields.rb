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
      end
    end
  end
end
