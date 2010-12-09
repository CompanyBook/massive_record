module MassiveRecord
  module ORM
    module Persistence
      extend ActiveSupport::Concern

      module ClassMethods
        def create(attributes = {})
          new(attributes).tap do |record|
            record.save
          end
        end
      end


      def new_record?
        @new_record
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      def destroyed?
        @destroyed
      end


      def reload
        self.attributes_raw = self.class.find(id).attributes
        self
      end
      
      def save(*)
        create_or_update
      end

      def save!(*)
        create_or_update or raise RecordNotSaved
      end

      def touch
        true
      end

      def destroy
        @destroyed = true
        true
      end

      def delete
        @destroyed = true
        true
      end


      private


      def create_or_update
        !!(new_record? ? create : update)
      end

      def create
        row = row_for_record

        @new_record = false
        true
      end

      def update(attribute_names_to_update = attributes.keys)
        row = row_for_record
        
        true
      end



      def row_for_record
        raise IdMissing.new("You must set an ID before save.") if id.blank?

        MassiveRecord::Wrapper::Row.new({
          :id => id,
          :table => self.class.table
        })
      end
    end
  end
end
