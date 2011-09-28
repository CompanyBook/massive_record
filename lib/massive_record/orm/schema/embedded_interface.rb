require 'massive_record/orm/schema/common_interface'

module MassiveRecord
  module ORM
    module Schema
      module EmbeddedInterface
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
          # class Person < MassiveRecord::ORM::Embedded
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
            add_field :updated_at, :time
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


          #
          # Returns attributes in embedded object from raw data. Raw
          # data's keys might different from a field name, if :column
          # option has been used.
          #
          def transpose_raw_data_to_record_attributes_and_raw_data(id, raw_data)
            attributes = {:id => id}

            updated_at = raw_data.created_at
            raw_attributes =  if raw_data.value.is_a? String
                                Base.coder.load(raw_data.value)
                              else
                                raw_data.value
                              end

            raw_data = Hash[raw_attributes.each do |attr, value|
              [attr, RawData.new(value: value, created_at: updated_at)]
            end]

            attributes_schema.each do |attr_name, orm_field|
              value = raw_attributes.has_key?(orm_field.column) ? raw_attributes[orm_field.column] : nil
              attributes[attr_name] = value.nil? ? nil : orm_field.decode(raw_attributes[orm_field.column])
            end

            [attributes, raw_data]
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
        # Returns attributes as a hash which has correct keys
        # based on it's field definition. For instance, you can
        # have a class with a field :attr_name, :column => :stored_as_this
        #
        def attributes_db_raw_data_hash(only_attr_names = [])
          values = Hash.new

          attributes_schema.each do |attr_name, orm_field|
            next unless only_attr_names.empty? || only_attr_names.include?(attr_name)
            values[orm_field.column] = orm_field.encode(send(attr_name))
          end

          values
        end

        def attributes_to_row_values_hash(only_attr_names = [])
          ActiveSupport::Deprecation.warn("attributes_to_row_values_hash is deprecated. Please use attributes_db_raw_data_hash")
          attributes_db_raw_data_hash(only_attr_names)
        end
      end
    end
  end
end
