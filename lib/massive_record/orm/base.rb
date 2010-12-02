require 'active_model'
require 'massive_record/orm/errors'
require 'massive_record/orm/attribute_methods'
require 'massive_record/orm/attribute_methods/write'
require 'massive_record/orm/attribute_methods/read'
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
        @new_record = false
        @destroyed = false

        self.attributes = coder['attributes']

        _run_find_callbacks
        _run_initialize_callbacks
      end





      include Persistence
      include ActiveModel::Translation
      include AttributeMethods
      include AttributeMethods::Write, AttributeMethods::Read
      include Validations
      include Naming      
      include Callbacks
    end
  end
end

require 'massive_record/orm/table'
require 'massive_record/orm/column'
