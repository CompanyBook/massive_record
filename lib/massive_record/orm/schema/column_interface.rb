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

          def add_field(*args)
            ensure_fields_exists

            field = Field.new_with_arguments_from_dsl(*args)
            fields << field

            undefine_attribute_methods if respond_to? :undefine_attribute_methods

            field
          end

          #
          # Entrypoint for the CommonInterface
          #
          def schema_source
            fields
          end

          private
          def ensure_fields_exists
            self.fields = Fields.new if fields.nil?
          end
        end

        def add_field(*args)
          new_field = self.class.add_field(*args)
          method = "#{new_field.name}="
          send(method, new_field.default) if respond_to? method
        end
      end
    end
  end
end
