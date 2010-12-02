require 'active_model'
require 'massive_record/orm/errors'
require 'massive_record/orm/attribute_methods'
require 'massive_record/orm/validations'
require 'massive_record/orm/naming'
require 'massive_record/orm/column_family'
require 'massive_record/orm/callbacks'
require 'massive_record/orm/persistence'

module MassiveRecord
  module ORM
    class Base

      class << self
        #
        # Just a dummy version of this to make callbacks work
        #
        def find(id, attributes = {})
          instantiate({:id => id}.merge(attributes))
        end

        private

        def instantiate(record)
          allocate.tap do |model|
            model.init_with('attributes' => record)
          end
        end
      end



      #
      # Initialize a new object. Send in attributes which
      # we'll dynamically set up read- and write methods for
      # and assign to instance variables. How read- and write 
      # methods are defined might change over time when the DSL
      # for describing column families and fields are in place
      #
      def initialize(attributes = {})
        @attributes = attributes_from_field_definition
        @new_record = true
        @destroyed = false

        self.attributes = attributes
        
        define_read_write_methods_for attributes.keys

        _run_initialize_callbacks
      end

      # Initialize an empty model object from +coder+.  +coder+ must contain
      # the attributes necessary for initializing an empty model object.  For
      # example:
      #
      # This should be used after finding a record from the database, as it will
      # trust the coder's attributes and not load it with default values.
      #
      #   class Person < MassiveRecord::ORM::Table
      #   end
      #
      #   person = Person.allocate
      #   person.init_with('attributes' => { 'name' => 'Alice' })
      #   person.name # => 'Alice'
      def init_with(coder)
        @attributes = coder['attributes']
        @new_record = false
        @destroyed = false

        define_read_write_methods_for @attributes.keys

        _run_find_callbacks
        _run_initialize_callbacks
      end




      private

      # TEMP - just to make things work as previously
      def attributes=(attrs)
        @attributes = attrs
      end

      # TEMP - just to make things work as previously
      def define_read_write_methods_for(attributes)
        attributes.each do |attribute|
          class_eval do
            define_method(attribute) do
              @attributes[attribute]
            end

            define_method("#{attribute}=") do |new_value|
              @attributes[attribute] = new_value
            end
          end
        end
      end





      include Persistence
      include ActiveModel::Translation
      include AttributeMethods
      include Validations
      include Naming      
      include Callbacks
    end
  end
end

require 'massive_record/orm/table'
require 'massive_record/orm/column'
