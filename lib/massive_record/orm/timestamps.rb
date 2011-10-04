module MassiveRecord
  module ORM
    module Timestamps
      extend ActiveSupport::Concern


      included do
        before_create :if => :set_created_at_on_create? do
          raise "created_at must be of type time" if attributes_schema['created_at'].type != :time
          @attributes['created_at'] = Time.now
        end

        before_create do
          @attributes['updated_at'] = @attributes['created_at'] || Time.now
        end
      end



      
      module ClassMethods
        private

        def transpose_hbase_row_to_record_attributes_and_raw_data(row)
          super.tap do |attributes, raw_values|
            attributes['updated_at'] = row.updated_at
            attributes
          end
        end
      end




      def updated_at
        self.class.time_zone_aware_attributes ? self['updated_at'].try(:in_time_zone) : self['updated_at']
      end

      def updated_at=(time)
        write_attribute :updated_at, time
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
        # Sets updated at to Time.now, even though the updated at is
        # read from the cell's time stamp on relad. We do this after
        # a successfully update to remove the need to do a query to
        # the db again to get the updated at timestamp.
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
