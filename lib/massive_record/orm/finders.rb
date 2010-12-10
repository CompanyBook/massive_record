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
          find_many = type == :all
          expected_result_size = nil
          
          rows =  if type
                    table.send(type, *args) # first() / all()
                  else
                    options = args.extract_options!
                    ids = args.first

                    if args.first.kind_of?(Array)
                      find_many = true
                    elsif args.length > 1
                      find_many = true
                      ids = args
                    end

                    expected_result_size = ids.length if ids.is_a? Array
                    table.find(ids, options)
                  end
          
          raise RecordNotFound if rows.blank?
          
          if expected_result_size && expected_result_size != rows.length
            raise RecordNotFound.new("Expected to find #{expected_result_size} records, but found only #{rows.length}")
          end
          
          results = [rows].flatten.collect do |row|
            instantiate(transpose_hbase_columns_to_record_attributes(row))
          end

          find_many ? results : results.first
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
            attributes[field.name] = column.nil? ? nil : column.deserialize_value
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
