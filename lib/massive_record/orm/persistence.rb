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
        row.values = attributes_to_row_values_hash(attribute_names_to_update)
        row.save
      end


      #
      # Returns a Wrapper::Row class which we can manipulate this
      # record in the database with
      #
      def row_for_record
        raise IdMissing.new("You must set an ID before save.") if id.blank?

        MassiveRecord::Wrapper::Row.new({
          :id => id,
          :table => self.class.table
        })
      end

      #
      # Returns attributes on a form which Wrapper::Row expects
      #
      def attributes_to_row_values_hash(only_attr_names = [])
        values = Hash.new { |hash, key| hash[key] = Hash.new }

        attributes_schema.each do |attr_name, orm_field|
          next unless only_attr_names.empty? || only_attr_names.include?(attr_name)
          values[orm_field.column_family][attr_name] = send(attr_name)
        end

        values
      end
    end
  end
end
