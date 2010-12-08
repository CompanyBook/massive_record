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
        @new_record = false
        true
      end

      def update(attribute_names_to_update = attributes.keys)
        true
      end


      def attributes_from_field_definition
        attributes = {'id' => nil}
        attributes.merge! default_attributes_from_schema if respond_to? :default_attributes_from_schema
        attributes
      end
    end
  end
end
