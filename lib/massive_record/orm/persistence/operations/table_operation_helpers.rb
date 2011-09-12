require 'massive_record/orm/query_instrumentation'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        module TableOperationHelpers

          def self.included(base)
            base.class_eval do
              include MassiveRecord::ORM::QueryInstrumentation::Operations
            end
          end


          #
          # Calculate which column families are missing in the database in
          # context of what the schema instructs.
          #
          def self.calculate_missing_family_names(klass)
            existing_family_names = klass.table.fetch_column_families.collect(&:name) rescue []
            expected_family_names = klass.column_families ? klass.column_families.collect(&:name) : []

            expected_family_names.collect(&:to_s) - existing_family_names.collect(&:to_s)
          end

          #
          # Creates table for ORM classes
          #
          def self.hbase_create_table!(klass)
            missing_family_names = calculate_missing_family_names(klass)
            klass.table.create_column_families(missing_family_names) unless missing_family_names.empty?
            klass.table.save
          end

          #
          # Iterates over tables and column families and ensure that we
          # have what we need
          #
          def ensure_that_we_have_table_and_column_families! # :nodoc:
            #
            # TODO: Can we skip checking if it exists at all, and instead, rescue it if it does not?
            #
            hbase_create_table! unless klass.table.exists?
            raise ColumnFamiliesMissingError.new(klass, calculate_missing_family_names) if calculate_missing_family_names.any?
          end

          def hbase_create_table!
            TableOperationHelpers.hbase_create_table!(klass)
          end


          def calculate_missing_family_names
            TableOperationHelpers.calculate_missing_family_names(klass)
          end





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
