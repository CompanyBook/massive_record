module MassiveRecord
  module ORM
    module Finders
      extend ActiveSupport::Concern

      included do
        class << self
          delegate :find, :first, :last, :all, :select, :limit, :to => :finder_scope
        end

        class_attribute :default_scoping, :instance_writer => false
      end

      module ClassMethods
        def do_find(*args) # :nodoc:
          options = args.extract_options!.to_options
          raise ArgumentError.new("At least one argument required!") if args.empty?
          raise RecordNotFound.new("Can't find a #{model_name.human} without an ID.") if args.first.nil?
          raise ArgumentError.new("Sorry, conditions are not supported!") if options.has_key? :conditions

          skip_expected_result_check = options.delete(:skip_expected_result_check)

          args << options

          type = args.shift if args.first.is_a? Symbol
          find_many = type == :all
          expected_result_size = nil

          return (find_many ? [] : raise(RecordNotFound.new("Could not find #{model_name} with id=#{args.first}"))) unless table.exists?
          
          result_from_table = if type
                                table.send(type, *args) # first() / all()
                              else
                                options = args.extract_options!
                                what_to_find = args.first
                                expected_result_size = 1

                                if args.first.kind_of?(Array)
                                  find_many = true
                                elsif args.length > 1
                                  find_many = true
                                  what_to_find = args
                                end

                                expected_result_size = what_to_find.length if what_to_find.is_a? Array
                                table.find(what_to_find, options)
                              end

          # Filter out unexpected IDs (unless type is set (all/first), in that case
          # we have no expectations on the returned rows' ids)
          unless type || result_from_table.blank?
            if find_many
              result_from_table.select! { |result| what_to_find.include? result.try(:id) }
            else 
              if result_from_table.id != what_to_find
                result_from_table = nil
              end
            end
          end

          raise RecordNotFound.new("Could not find #{model_name} with id=#{what_to_find}") if result_from_table.blank? && type.nil?
          
          if find_many && !skip_expected_result_check && expected_result_size && expected_result_size != result_from_table.length
            raise RecordNotFound.new("Expected to find #{expected_result_size} records, but found only #{result_from_table.length}")
          end
          
          records = [result_from_table].compact.flatten.collect do |row|
            instantiate(transpose_hbase_columns_to_record_attributes(row))
          end

          find_many ? records : records.first
        end

        def find_in_batches(*args)
          return unless table.exists?

          table.find_in_batches(*args) do |rows|
            records = rows.collect do |row|
              instantiate(transpose_hbase_columns_to_record_attributes(row))
            end    
            yield records
          end
        end
        
        def find_each(*args)
          find_in_batches(*args) do |rows|
            rows.each do |row|
              yield row
            end
          end
        end


        def exists?(id)
          !!find(id) rescue false
        end


        def finder_scope
          default_scoping || unscoped
        end

        def default_scope(scope)
          self.default_scoping =  case scope
                                    when Scope, nil
                                      scope
                                    when Hash
                                      Scope.new(self, :find_options => scope)
                                    else
                                      raise "Don't know how to set scope with #{scope.class}."
                                    end
        end

        def unscoped
          Scope.new(self)
        end


        private

        def transpose_hbase_columns_to_record_attributes(row)
          attributes = {:id => row.id}
          
          autoload_column_families_and_fields_with(row.columns.keys)

          # Parse the schema to populate the instance attributes
          attributes_schema.each do |key, field|
            cell = row.columns[field.unique_name]
            attributes[field.name] = cell.nil? ? nil : cell.deserialize_value
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
