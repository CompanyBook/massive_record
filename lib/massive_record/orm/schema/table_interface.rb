module MassiveRecord
  module ORM
    module Schema
      module TableInterface
        extend ActiveSupport::Concern

        included do
          class_attribute :column_families, :instance_writer => false
          self.column_families = nil
        end


        module ClassMethods
          def column_family(name, &block)
            ensure_column_families_exists
            column_families.family_by_name_or_new(name).instance_eval(&block)
          end

          def add_field_to_column_family(family_name, *field_args)
            ensure_column_families_exists

            field_options = field_args.extract_options!
            field_options[:name] = field_args[0]
            field_options[:type] = field_args[1]

            column_families.family_by_name_or_new(family_name) << Field.new(field_options)
            undefine_attribute_methods if respond_to? :undefine_attribute_methods
          end

          def known_attribute_names
            column_families.present? ? column_families.attribute_names : []
          end

          def attributes_schema
            column_families.present? ? column_families.to_hash : {}
          end

          def default_attributes_from_schema
            defaults = {}
            attributes_schema.each { |attribute_name, field| defaults[attribute_name] = field.default }
            defaults
          end

          def autoloaded_column_family_names
            column_families.present? ? column_families.families_with_auto_loading_fields.collect(&:name) : []
          end


          private
          def ensure_column_families_exists
            self.column_families = ColumnFamilies.new if column_families.nil?
          end
        end


        def attributes_schema
          self.class.attributes_schema
        end
      end
    end
  end
end
