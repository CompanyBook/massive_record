module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module TableOperationHelpers
          #
          # Returns a Wrapper::Row class which we can manipulate this
          # record in the database with
          #
          def row_for_record
            raise IdMissing.new("You must set an ID before save.") if record.id.blank?

            MassiveRecord::Wrapper::Row.new({
              :id => record.id,
              :table => klass.table
            })
          end

          #
          # Returns attributes on a form which Wrapper::Row expects
          #
          def attributes_to_row_values_hash(only_attr_names = [])
            values = Hash.new { |hash, key| hash[key] = Hash.new }

            record.attributes_schema.each do |attr_name, orm_field|
              next unless only_attr_names.empty? || only_attr_names.include?(attr_name)
              values[orm_field.column_family.name][orm_field.column] = orm_field.encode(record[attr_name])
            end

            values
          end


          #
          # Takes care of the actual storing of the record to the database
          # Both update and create is using this
          #
          def store_record_to_database(action, attribute_names_to_update = [])
            row = row_for_record
            row.values = attributes_to_row_values_hash(attribute_names_to_update)
            row.save
          end
        end
      end
    end
  end
end
