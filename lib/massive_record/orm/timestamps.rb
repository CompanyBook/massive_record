module MassiveRecord
  module ORM
    module Timestamps
      extend ActiveSupport::Concern


      included do
        before_create :if => :set_created_at_on_create? do
          raise "created_at must be of type time" if attributes_schema['created_at'].type != :time
          @attributes['created_at'] = Time.now
        end
      end



      
      module ClassMethods
        private

        def transpose_hbase_columns_to_record_attributes(row)
          attributes = super
          attributes['updated_at'] = row.updated_at
          attributes
        end
      end




      def updated_at
        self.class.time_zone_aware_attributes ? self['updated_at'].try(:in_time_zone) : self['updated_at']
      end

      def write_attribute(attr_name, value)
        attr_name = attr_name.to_s

        if attr_name == 'updated_at' || (attr_name == 'created_at' && has_created_at?)
          raise MassiveRecord::ORM::CantBeManuallyAssigned.new("#{attr_name} can't be manually assigned.")
        end

        super
      end



      private

      def update(*)
        # Not 100% accurat, as we might should re-read the saved row from
        # the database to fetch exactly the correct updated at time, but
        # it should do for now as it takes an extra query to check the time stamp.
        @attributes['updated_at'] = Time.now if updated = super 
        updated
      end

      def set_created_at_on_create?
        has_created_at?
      end

      def has_created_at?
        known_attribute_names.include? 'created_at'
      end

      def known_attribute_names_for_inspect
        out = (super rescue []) << 'updated_at'
      end
    end
  end
end
