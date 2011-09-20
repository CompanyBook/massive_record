require 'massive_record/orm/persistence/operations'

module MassiveRecord
  module ORM
    module Persistence
      extend ActiveSupport::Concern


      module ClassMethods
        def create(*args)
          new(*args).tap do |record|
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
        if persisted?
          self.class.find(id).tap do |record|
            self.attributes_raw = record.attributes
            @raw_data = record.raw_data
          end
        end
        self
      end
      
      def save(*)
        create_or_update
      end

      def save!(*)
        create_or_update or raise RecordNotSaved
      end

      def update_attribute(attr_name, value)
        self[attr_name] = value
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
        @destroyed = (persisted? ? Operations.destroy(self).execute : true) and freeze
      end
      alias_method :delete, :destroy


      def change_id!(new_id)
        old_id, self.id = id, new_id

        @new_record = true
        unless save
          raise <<-TXT
            Unable to save #{self.class} with updated id '#{new_id}'.
            Old id '#{old_id}' was not deleted so in theory nothing should be changed in the database.
          TXT
        end

        unless self.class.find(old_id).destroy
          raise <<-TXT
            Unable to destroy #{self.class} with id '#{old_id}'.
            You now how duplicate records in the database. New id is: '#{new_id}.'
          TXT
        end

        reload
      end


      def increment(attr_name, by = 1)
        raise NotNumericalFieldError unless attributes_schema[attr_name.to_s].type == :integer
        self[attr_name] ||= 0
        self[attr_name] += by
        self
      end

      def increment!(attr_name, by = 1)
        increment(attr_name, by).update_attribute(attr_name, self[attr_name])
      end

      def atomic_increment!(attr_name, by = 1)
        atomic_operation(:increment, attr_name, by)
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

      def atomic_decrement!(attr_name, by = 1)
        atomic_operation(:decrement, attr_name, by)
      end

      

      private


      def create_or_update
        raise ReadOnlyRecord if readonly?
        !!(new_record? ? create : update)
      end

      def create
        Operations.insert(self).execute.tap do |saved|
          @new_record = false if saved
        end
      end

      def update(attribute_names_to_update = attributes_with_embedded)
        Operations.update(self, :attribute_names_to_update => attribute_names_to_update).execute
      end

      #
      # Atomic decrement of an attribute. Please note that it's the
      # adapter (or the wrapper) which needs to guarantee that the update
      # is atomic. Thrift adapter is working with atomic decrementation.
      #
      def atomic_operation(operation, attr_name, by)
        Operations.atomic_operation(self, :operation => operation, :attr_name => attr_name, :by => by).execute
      end



      #
      # Gives you all attribute names pluss all known embedded
      # attributes names. Is used if dirty is active.
      #
      def attributes_with_embedded
        attributes.keys | relation_proxies_for_embedded.collect { |proxy| proxy.metadata.name }
      end
    end
  end
end
