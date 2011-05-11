module MassiveRecord
  module ORM
    module SingleTableInheritance
      extend ActiveSupport::Concern

      included do
        after_initialize :ensure_proper_type
      end


      module ClassMethods

        private

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
