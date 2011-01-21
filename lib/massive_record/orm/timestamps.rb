module MassiveRecord
  module ORM
    module Timestamps
      extend ActiveSupport::Concern

      
      module ClassMethods
        
        
        private

        def transpose_hbase_columns_to_record_attributes(row)
          attributes = super
          attributes['updated_at'] = row.updated_at
          attributes
        end
      end




      def updated_at
        self['updated_at']
      end

      def write_attribute(attr_name, value)
        raise "Can't be set manually." if attr_name.to_s == 'updated_at'  
        super
      end
    end
  end
end
