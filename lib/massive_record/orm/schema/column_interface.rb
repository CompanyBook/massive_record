require 'massive_record/orm/schema/common_interface'

module MassiveRecord
  module ORM
    module Schema
      module ColumnInterface
        extend ActiveSupport::Concern

        included do
          include CommonInterface

          class_attribute :fields, :instance_writer => false
          self.fields = nil
        end

        module ClassMethods
          #
          # DSL method exposed into class. Makes it possible to do:
          #
          # class Person < MassiveRecord::ORM::Column
          #  field :name
          #  field :age, :integer, :default => 0
          #  field :points, :integer, :column => :number_of_points
          # end
          #
          #
          def field(*args)
            ensure_fields_exists
            fields << Field.new_with_arguments_from_dsl(*args)
          end


          def timestamps
            add_field :created_at, :time
          end

          #
          # If you need to add fields dynamically, use this method.
          # It wraps functionality needed to keep the class in a consistent state.
          # There is also an instance method defined which will inject default value
          # to the object itself after defining the field.
          #
          def add_field(*args)
            ensure_fields_exists

            field = Field.new_with_arguments_from_dsl(*args)
            fields << field

            undefine_attribute_methods if respond_to? :undefine_attribute_methods

            field
          end




          private
          #
          # Entrypoint for the CommonInterface
          #
          def schema_source
            fields
          end

          def ensure_fields_exists
            self.fields = Fields.new if fields.nil?
          end
        end

        #
        # Same as defined in class method, but also sets the default value
        # in current object it was called from.
        #
        def add_field(*args)
          new_field = self.class.add_field(*args)
          method = "#{new_field.name}="
          send(method, new_field.default) if respond_to? method
        end
        
        #
        # TODO : Need to be cleaned up after we implement the has_many method
        #
        def attributes_to_row_values_hash(only_attr_names = [])
          values = Hash.new

          attributes_schema.each do |attr_name, orm_field|
            next unless only_attr_names.empty? || only_attr_names.include?(attr_name)
            values[orm_field.column] = orm_field.encode(send(attr_name))
          end

          values
        end
      end
    end
  end
end
