require 'massive_record/orm/persistence/operations/table_operation_helpers'

module MassiveRecord
  module ORM
    module Persistence
      module Operations
        class AtomicOperation
          include Operations, TableOperationHelpers

          def execute
            raise NotNumericalFieldError unless record.attributes_schema[attr_name].type == :integer

            klass.ensure_that_we_have_table_and_column_families!
            ensure_proper_binary_integer_representation(attr_name)
            record[attr_name] = row_for_record.send("atomic_#{operation}", record.attributes_schema[attr_name].unique_name, by)
          ensure
            record.instance_variable_set(:@new_record, false)
          end


          private

          #
          # To cope with the problem which arises when you ask to
          # do atomic incrementation / decrementation of an attribute and that attribute
          # has a string representation of a number, like "1", instead of
          # the binary representation, like "\x00\x00\x00\x00\x00\x00\x00\x01".
          #
          # We then need to re-write that string representation into
          # hex representation. Now, if you are on a completely new
          # database and have never used MassiveRecord before we should not
          # need to do this at all; numbers are now stored as hex, but for
          # backward compatibility we are doing this.
          #
          # Now, there is a risk of doing this; if two calls are made to
          # atomic_increment! or atomic_decrement! on a record where it's value is a string
          # representation this operation might be compromised. Therefor
          # you need to enable this feature.
          #
          def ensure_proper_binary_integer_representation(attr_name)
            return if !klass.backward_compatibility_integers_might_be_persisted_as_strings || record.new_record?

            field = record.attributes_schema[attr_name]

            if raw_value = klass.table.get(record.id, field.column_family.name, field.name)
              store_record_to_database('update', [attr_name]) if raw_value =~ /\A\d*\Z/
            end
          end


          def operation
            options[:operation] or raise "Missing option :operation"
          end

          def attr_name
            @attr_name ||= if options[:attr_name].present?
                             options[:attr_name].to_s
                           else
                             raise "Missing option :attr_name"
                           end
          end

          def by
            options[:by] or raise "Missing option :by"
          end
        end
      end
    end
  end
end
        
