module MassiveRecord
  module ORM
    module Finders
      extend ActiveSupport::Concern

      module ClassMethods
        #
        # Interface for retrieving objects based on key.
        # Has some convenience behaviour like find :first, :last, :all.
        #
        def find(*args)
          raise ArgumentError.new("At least one argument required!") if args.empty?
          raise RecordNotFound.new("Can't find a #{model_name.human} without an ID.") if args.first.nil?

          type = args.shift if args.first.is_a? Symbol

          row = if type
                  table.send(type, *args)
                else
                  table.find(*args)
                end

          raise RecordNotFound if row.blank?
          
          results = [row].flatten.collect do |row|
            instantiate(transpose_hbase_columns_to_record_attributes(row))
          end

          type && type == :all ? results : results.first
        end

        def first(*args)
          find(:first, *args)
        end

        def last(*args)
          raise "Sorry, not implemented!"
        end

        def all(*args)
          find(:all, *args)
        end



        private

        def transpose_hbase_columns_to_record_attributes(row)
          attributes = {:id => row.id}
          attributes_schema.each do |key, field|
            column = row.columns[field.unique_name]
            attributes[field.name] = column.nil? ? nil : column.value
          end
          attributes
        end

        def instantiate(record)
          allocate.tap do |model|
            model.init_with('attributes' => record)
          end
        end
      end
    end
  end
end
