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

        def destroy_all
          all.each { |record| record.destroy }
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

      def update_attribute(attr_name, value)
        send("#{attr_name}=", value)
        save(:validate => false)
      end

      def update_attributes(attributes)
        self.attributes = attributes
        save
      end

      def update_attributes!(attributes)
        self.attributes = attributes
        save!
      end

      # TODO  This actually does nothing atm, but it's here and callbacks on it
      #       is working.
      def touch
        true
      end

      def destroy
        @destroyed = row_for_record.destroy and freeze
      end
      alias_method :delete, :destroy




      def increment(attr_name, by = 1)
        raise NotNumericalFieldError unless attributes_schema[attr_name.to_s].type == :integer
        self[attr_name] ||= 0
        self[attr_name] += by
        self
      end

      def increment!(attr_name, by = 1)
        increment(attr_name, by).update_attribute(attr_name, self[attr_name])
      end

      # Atomic increment of an attribute. Please note that it's the
      # adapter (or the wrapper) which needs to guarantee that the update
      # is atomic, and as of writing this the Thrift adapter / wrapper does
      # not do this anatomic.
      def atomic_increment!(attr_name, by = 1)
        ensure_that_we_have_table_and_column_families!
        attr_name = attr_name.to_s

        row = row_for_record
        row.values = attributes_to_row_values_hash([attr_name])
        self[attr_name] = row.atomic_increment(attributes_schema[attr_name].unique_name, by).to_i
      end

      def decrement(attr_name, by = 1)
        raise NotNumericalFieldError unless attributes_schema[attr_name.to_s].type == :integer
        self[attr_name] ||= 0
        self[attr_name] -= by
        self
      end

      def decrement!(attr_name, by = 1)
        decrement(attr_name, by).update_attribute(attr_name, self[attr_name])
      end
      

      private


      def create_or_update
        !!(new_record? ? create : update)
      end

      def create
        ensure_that_we_have_table_and_column_families!

        if saved = store_record_to_database
          @new_record = false
        end
        saved
      end

      def update(attribute_names_to_update = attributes.keys)
        ensure_that_we_have_table_and_column_families!

        store_record_to_database(attribute_names_to_update)
      end




      #
      # Takes care of the actual storing of the record to the database
      # Both update and create is using this
      #
      def store_record_to_database(attribute_names_to_update = [])
        row = row_for_record
        row.values = attributes_to_row_values_hash(attribute_names_to_update)
        row.save
      end


      #
      # Iterates over tables and column families and ensure that we
      # have what we need
      #
      def ensure_that_we_have_table_and_column_families!
        if !self.class.connection.tables.include? self.class.table_name
          missing_family_names = calculate_missing_family_names
          self.class.table.create_column_families(missing_family_names) unless missing_family_names.empty?
          self.class.table.save
        end

        raise ColumnFamiliesMissingError.new(calculate_missing_family_names) if !calculate_missing_family_names.empty?
      end
      
      #
      # Calculate which column families are missing in the database in
      # context of what the schema instructs.
      #
      def calculate_missing_family_names
        existing_family_names = self.class.table.fetch_column_families.collect(&:name) rescue []
        expected_family_names = column_families ? column_families.collect(&:name) : []

        expected_family_names.collect(&:to_s) - existing_family_names.collect(&:to_s)
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
          values[orm_field.column_family.name][orm_field.column] = send(attr_name)
        end

        values
      end
    end
  end
end
