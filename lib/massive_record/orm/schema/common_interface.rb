module MassiveRecord
  module ORM
    module Schema
      #
      # Common methods both shared with table interface and field interface.
      # Methods are to be included as ClassMethods, and where they are to be
      # included must provide a schema_source(). Currently it is expected to
      # be a set of Schema::ColumnFamilies or a set of Schema::Fields, but
      # I guess as long as it responds to to_hash and attribute_names you are fine.
      #
      module CommonInterface
        extend ActiveSupport::Concern

        module ClassMethods
          #
          # Returns a hash where attribute names are keys and it's field
          # is the value.
          #
          def attributes_schema
            (self.superclass.superclass == Base) ? schema_by_klass : schema_source.to_hash
          end

          def schema_by_klass
            unless @schema_by_klass
              @schema_by_klass = Hash.new
            end

            if @schema_by_klass[class_column_key].nil? || @schema_by_klass[class_column_key] == {}
              @schema_by_klass[class_column_key] = schema_source.present? ? schema_source.to_hash : {}
            end

            @schema_by_klass[class_column_key]
          end

          def clear_schema_cache
            if @schema_by_klass
              @schema_by_klass[class_column_key] = nil
            end
          end

          #
          # Returns an array of known attributes based on all fields found
          # in schema source
          #
          def known_attribute_names
            schema_source.present? ? schema_source.attribute_names : []
          end


          #
          # Returns a hash with attribute name as keys, default values read from field as value.
          #
          def default_attributes_from_schema
            Hash[attributes_schema.collect { |attribute_name, field|
              [attribute_name, field.default]
            }]
          end

          private

          def class_column_key
            self.table.name
          end
        end

        def attributes_schema
          self.class.attributes_schema
        end

        def known_attribute_names
          self.class.known_attribute_names
        end
      end
    end
  end
end
