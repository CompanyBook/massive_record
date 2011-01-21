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



      private

      def update(*)
        super
        # Not 100% accurat, as we might should re-read the saved row from
        # the database to fetch exactly the correct updated at time, but
        # it should do for now as it takes an extra query to check the time stamp.
        @attributes['updated_at'] = Time.now
      end

      def known_attribute_names_for_inspect
        (super rescue []) << 'updated_at'
      end
    end
  end
end
