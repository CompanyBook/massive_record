module MassiveRecord
  module ORM
    module SingleTableInheritance
      extend ActiveSupport::Concern

      # 
      # Raised if you call first on any sub class of your base class.
      # Calling first() on a sub class can't be easily done through
      # thrift as we can't apply any column filter on the STI type column.
      # 
      # What you need to do is, the very inefficient, SubClass.all.first
      # When doing an all, all records will be fetched, but at least the
      # array or records will be filtered and only correct class will be
      # returned.
      #
      class FirstUnsupported < MassiveRecordError; end


      included do
        after_initialize :ensure_proper_type
      end


      module ClassMethods
        def do_find(*args)
          result = super
          single_table_inheritance_enabled? ? ensure_only_class_or_subclass_of_self_are_returned(result) : result
        end

        def first(*args)
          if base_class == self
            super
          else
            raise FirstUnsupported.new("Sorry, first() on '#{self}' (sub class of the base class '#{base_class}') is unsupported due to unable to efficiently filter this through Thrift.")
          end
        end

        private

        def ensure_only_class_or_subclass_of_self_are_returned(result)
          multiple_result = result.is_a? Array
          filtered_results = (multiple_result ? result : [result]).select { |result| result.kind_of? self }
          multiple_result ? filtered_results : filtered_results.first
        end

        #
        # In Rails development environment class files are not required before they are needed.
        #
        # transpose_hbase_columns_to_record_attributes uses attributes_schema and
        # for attributes_schema to have loaded all of it's fields correctly we need
        # to make sure Rails loads class file before attributes_schema renders it's schema.
        #
        def transpose_hbase_columns_to_record_attributes(row) # :nodoc:
          if field = attributes_schema[inheritance_attribute]
            if cell_with_record_sti_class = row.columns[field.unique_name] and cell_with_record_sti_class.present?
              if klass = field.decode(cell_with_record_sti_class.value) and klass.present?
                ensure_sti_class_is_loaded(klass)
              end
            end
          end

          super
        end

        def ensure_sti_class_is_loaded(klass) # :nodoc:
          klass.constantize
        end

        def single_table_inheritance_enabled?
          !!attributes_schema[inheritance_attribute]
        end
      end


      def ensure_proper_type
        inheritance_attribute = self.class.inheritance_attribute

        if respond_to?(inheritance_attribute) && self[inheritance_attribute].blank? && self.class.base_class != self.class
          self[inheritance_attribute] = self.class.to_s
        end
      end
    end
  end
end
