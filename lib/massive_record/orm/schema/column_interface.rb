module MassiveRecord
  module ORM
    module Schema
      module ColumnInterface
        extend ActiveSupport::Concern

        included do
          class_attribute :fields, :instance_writer => false
          self.fields = nil
        end

        module ClassMethods
          #
          # DSL method exposed into class. Makes it possible to do:
          #
          # class Person < MassiveRecord::ORM::Table
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

          #
          # Returns a hash where attribute names are keys and it's field
          # is the value.
          #
          def attributes_schema
            fields.present? ? fields.to_hash : {}
          end

          #
          # Returns an array of known attributes based on all fields found
          # in all column families.
          #
          def known_attribute_names
            fields.present? ? fields.attribute_names : []
          end


          #
          # Returns a hash with attribute name as keys, default values read from field as value.
          #
          def default_attributes_from_schema
            attributes_schema.inject({}) do |hash, (attribute_name, field)|
              hash[attribute_name] = field.default
              hash
            end
          end


          private
          def ensure_fields_exists
            self.fields = Fields.new if fields.nil?
          end
        end
      end
    end
  end
end
