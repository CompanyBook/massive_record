require 'active_model'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/subclasses'
require 'active_support/memoizable'

require 'massive_record/orm/errors'
require 'massive_record/orm/config'
require 'massive_record/orm/finders'
require 'massive_record/orm/field'
require 'massive_record/orm/fields'
require 'massive_record/orm/attribute_methods'
require 'massive_record/orm/attribute_methods/write'
require 'massive_record/orm/attribute_methods/read'
require 'massive_record/orm/attribute_methods/dirty'
require 'massive_record/orm/attribute_methods/schema'
require 'massive_record/orm/validations'
require 'massive_record/orm/column_family'
require 'massive_record/orm/callbacks'
require 'massive_record/orm/persistence'

module MassiveRecord
  module ORM
    class Base
      
      # Add a prefix or a suffix to the table name
      # example:
      #
      #   MassiveRecord::ORM::Base.table_name_prefix = "_production"
      class_attribute :table_name_prefix, :instance_writer => false
      self.table_name_prefix = ""
      
      class_attribute :table_name_suffix, :instance_writer => false
      self.table_name_suffix = ""
     
      class << self
        def table_name
          @table_name ||= table_name_prefix + self.to_s.demodulize.underscore.pluralize + table_name_suffix
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
        self.attributes_raw = attributes_from_field_definition.merge(attributes)
        self.attributes = attributes
        @new_record = true
        @destroyed = false

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

        self.attributes_raw = coder['attributes']

        _run_find_callbacks
        _run_initialize_callbacks
      end


      def to_param
        id.to_s if id.present?
      end


      def ==(other)
        other.equal?(self) || other.instance_of?(self.class) && id == other.id
      end
      alias_method :eql?, :==


      include Config
      include Persistence
      include Finders
      include ActiveModel::Translation
      include AttributeMethods
      include AttributeMethods::Schema, AttributeMethods::Write, AttributeMethods::Read
      include AttributeMethods::Dirty
      include Validations
      include Callbacks
    end
  end
end

require 'massive_record/orm/table'
require 'massive_record/orm/column'
