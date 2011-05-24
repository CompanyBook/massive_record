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
        #
        # Find records in batches. Makes it easier to work with
        # big data sets where you don't want to load every record up front.
        #
        def find_in_batches(*args)
          table.find_in_batches(*args) do |rows|
            records = rows.collect do |row|
              instantiate(transpose_hbase_columns_to_record_attributes(row))
            end    
            yield records
          end
        end
        
        #
        # Similar to all, except that this will use find_in_batches
        # behind the scene.
        #
        def find_each(*args)
          find_in_batches(*args) do |rows|
            rows.each do |row|
              yield row
            end
          end
        end


        #
        # Returns true if a record do exist
        #
        def exists?(id)
          !!find(id) rescue false
        end



        #
        # Entry point for method delegation like find, first, all etc.
        #
        def finder_scope
          default_scoping || unscoped
        end


        #
        # Sets a default scope which will be used for calls like find, first, all etc.
        # Makes it possible to for instance set default column families to load on all
        # calls to the database.
        #
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

        #
        # Returns an fresh scope object with no limitations set by
        # for instance the default scope
        #
        def unscoped
          Scope.new(self)
        end




        #
        # This do_find method is not very nice it's logic should be re-factored at some point.
        #
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
          what_to_find = []
          result_from_table = []
          
          find_many, expected_result_size, what_to_find, result_from_table = query_hbase(type, args, find_many)

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




        private

        def query_hbase(type, args, find_many) # :nodoc:
          result_from_table = if type
                                hbase_query_all_first(type, args)
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
                                hbase_query_find(what_to_find, options)
                              end

          [find_many, expected_result_size, what_to_find, result_from_table]
        end

        def hbase_query_all_first(type, args)
          table.send(type, *args) # first() / all()
        end

        def hbase_query_find(what_to_find, options)
          table.find(what_to_find, options)
        end

        def transpose_hbase_columns_to_record_attributes(row) #: nodoc:
          attributes = {:id => row.id}
          
          autoload_column_families_and_fields_with(row.columns.keys)

          # Parse the schema to populate the instance attributes
          attributes_schema.each do |key, field|
            cell = row.columns[field.unique_name]
            attributes[field.name] = cell.nil? ? nil : field.decode(cell.value)
          end
          attributes
        end

        def instantiate(record) # :nodoc:
          model = if klass = record[inheritance_attribute] and klass.present?
                    klass.constantize.allocate
                  else
                    allocate
                  end

          model.init_with('attributes' => record)
        end
      end
    end
  end
end
