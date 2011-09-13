module MassiveRecord
  module ORM
    module Finders
      extend ActiveSupport::Concern

      included do
        class << self
          delegate :find, :last, :all, :select, :limit, :starts_with, :offset, :to => :finder_scope
        end

        class_attribute :default_scoping, :instance_writer => false
      end

      module ClassMethods
        def first(*args)
          finder_scope.first(*args)
        end

        #
        # Find records in batches. Makes it easier to work with
        # big data sets where you don't want to load every record up front.
        #
        def find_in_batches(*args)
          table.find_in_batches(*args) do |rows|
            records = rows.collect do |row|
              instantiate(*transpose_hbase_row_to_record_attributes_and_raw_data(row))
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
          if default_scoping
            default_scoping.dup
          else
            unscoped
          end
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
                                      Scope.new(self).apply_finder_options(scope)
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
        # Method actually doing the find operation. It handles first, last (not supported though), all
        # and find records by id(s). It simply delegates to more spesific methods.
        #
        def do_find(*args) # :nodoc:
          options = args.extract_options!.to_options

          raise ArgumentError.new("Sorry, conditions are not supported!") if options.has_key? :conditions

          case args.first
          when :first, :last
            send(args.first, options)
          when :all
            find_all(options)
          else
            find_by_ids(*args, options)
          end
        end





        private



        def find_by_ids(*ids, options) # :nodoc:
          raise ArgumentError.new("At least one argument required!") if ids.empty?

          find_many = ids.first.is_a? Array
          ids = ids.flatten.compact.uniq

          case ids.length
          when 0
            raise RecordNotFound.new("Can't find a #{model_name.human} without an ID.")
          when 1
            record = find_one(ids.first, options)
            find_many ? [record] : record
          else
            find_some(ids, options)
          end
        end

        def find_one(id, options) # :nodoc:
          query_hbase(id, options).first.tap do |record|
            raise RecordNotFound.new("Could not find #{model_name} with id=#{id}") if record.nil? || record.id != id
          end
        end

        def find_some(ids, options) # :nodoc:
          expected_result_size = ids.length 

          query_hbase(ids, options).tap do |records|
            records.select! { |record| ids.include?(record.id) }

            if !options[:skip_expected_result_check] && records.length != expected_result_size
              raise RecordNotFound.new("Expected to find #{expected_result_size} records, but found only #{records.length}")
            end
          end
        end

        def find_all(options) # :nodoc:
          select_known_column_families_if_no_selections_are_added(options)
          query_hbase { table.all(options) }
        end


        def select_known_column_families_if_no_selections_are_added(options)
          unless options.has_key? :select
            default_selection = known_column_family_names
            options[:select] = default_selection if default_selection.any?
          end
        end



        #
        # Queries hbase. Either looks for what to find with given options
        # or yields the block and uses that as result when instantiate records from rows
        #
        def query_hbase(what_to_find = nil, options = nil) # :nodoc:
          result =  if block_given?
                      yield
                    else
                      select_known_column_families_if_no_selections_are_added(options)
                      table.find(what_to_find, options)
                    end

          ensure_id_is_utf8_encoded(Array(result).compact).collect do |row|
            instantiate_row_from_hbase(row)
          end
        rescue => e
          if e.is_a?(Apache::Hadoop::Hbase::Thrift::IOError) && e.message =~ /NoSuchColumnFamilyException/
            raise ColumnFamiliesMissingError.new(self, Persistence::Operations::TableOperationHelpers.calculate_missing_family_names(self))
          else
            raise e
          end
        end

        def instantiate_row_from_hbase(row)
          instantiate(*transpose_hbase_row_to_record_attributes_and_raw_data(row)) # :nodoc:
        end



        def instantiate(record, raw_data) # :nodoc:
          model = if record.has_key?(inheritance_attribute)
                    if klass = record[inheritance_attribute] and klass.present?
                      klass.constantize.allocate
                    else
                      base_class.allocate
                    end
                  else
                    allocate
                  end

          model.init_with('attributes' => record, 'raw_data' => raw_data)
        end



        def ensure_id_is_utf8_encoded(result_from_table) # :nodoc
          return nil if result_from_table.nil?

          if result_from_table.respond_to? :id
            result_from_table.id.force_encoding(Encoding::UTF_8) if result_from_table.id.respond_to? :force_encoding
          elsif result_from_table.respond_to? :each
            result_from_table.collect! { |result| ensure_id_is_utf8_encoded(result) }
          end

          result_from_table
        end

        def transpose_hbase_row_to_record_attributes_and_raw_data(row) # :nodoc:
          attributes = {:id => row.id}
          raw_data = row.values_hash
          
          autoload_column_families_and_fields_with(row.columns.keys)

          # Parse the schema to populate the instance attributes
          attributes_schema.each do |key, field|
            value = raw_data.has_key?(field.column_family.name) ? raw_data[field.column_family.name][field.column] : nil
            attributes[field.name] = value.nil? ? nil : field.decode(value)
          end

          [attributes, raw_data]
        end
      end
    end
  end
end
