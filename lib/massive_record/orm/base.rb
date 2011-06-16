require 'active_model'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/subclasses'
require 'active_support/core_ext/module'
require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'active_support/memoizable'

require 'massive_record/orm/schema'
require 'massive_record/orm/coders'
require 'massive_record/orm/errors'
require 'massive_record/orm/config'
require 'massive_record/orm/relations'
require 'massive_record/orm/finders'
require 'massive_record/orm/finders/scope'
require 'massive_record/orm/finders/rescue_missing_table_on_find'
require 'massive_record/orm/attribute_methods'
require 'massive_record/orm/attribute_methods/time_zone_conversion'
require 'massive_record/orm/attribute_methods/write'
require 'massive_record/orm/attribute_methods/read'
require 'massive_record/orm/attribute_methods/dirty'
require 'massive_record/orm/single_table_inheritance'
require 'massive_record/orm/validations'
require 'massive_record/orm/callbacks'
require 'massive_record/orm/timestamps'
require 'massive_record/orm/persistence'
require 'massive_record/orm/default_id'
require 'massive_record/orm/query_instrumentation'


module MassiveRecord
  module ORM
    class Base
      include ActiveModel::Conversion
      
      class_attribute :coder, :instance_writer => false
      self.coder = Coders::JSON.new

      # Accepts a logger conforming to the interface of Log4r or the default Ruby 1.8+ Logger class,
      cattr_accessor :logger, :instance_writer => false


      #
      # Integers are now persisted as a hax representation in hbase, not as
      # a string any more. This makes for instance atomic_increment!(:int_attr) work
      # as expected.
      #
      # The problem is that if you have old data in your database, you need to handle
      # this. Every new integer will still be written as hex though.
      #
      cattr_accessor :backward_compatibility_integers_might_be_persisted_as_strings, :instance_writer => false
      self.backward_compatibility_integers_might_be_persisted_as_strings = false


      # Add a prefix or a suffix to the table name
      # example:
      #
      #   MassiveRecord::ORM::Base.table_name_prefix = "_production"
      class_attribute :table_name_overriden, :instance_writer => false
      self.table_name_overriden = nil

      class_attribute :table_name_prefix, :instance_writer => false
      self.table_name_prefix = ""
      
      class_attribute :table_name_suffix, :instance_writer => false
      self.table_name_suffix = ""

      #
      # Will do a simple exists?(id) check before create as a simple (and
      # kinda insecure) sanity check on if that ID exists or not. If it do
      # exists a RecordNotUnique will be raised. This is done from the ORM
      # layer, so obviously there is a speed cost on create.
      #
      class_attribute :check_record_uniqueness_on_create, :instance_writer => false
      self.check_record_uniqueness_on_create = false

      class_attribute :auto_increment_id, :instance_writer => false
      self.auto_increment_id = true
     
      class << self
        def table_name
          @table_name ||= table_name_prefix + table_name_without_pre_and_suffix + table_name_suffix
        end

        def table_name_without_pre_and_suffix
          (table_name_overriden.blank? ? base_class.to_s.demodulize.underscore.pluralize : table_name_overriden)
        end

        def table_name=(name)
          self.table_name_overriden = name
        end
        alias :set_table_name :table_name=

        def reset_table_name_configuration!
          @table_name = self.table_name_overriden = nil
          self.table_name_prefix = self.table_name_suffix = ""
        end

        def base_class
          class_of_descendant(self)
        end


        def inheritance_attribute
          @inheritance_attribute ||= "type"
        end

        def set_inheritance_attribute(value = nil, &block)
          define_attr_method :inheritance_attribute, value, &block
        end
        alias :inheritance_attribute= :set_inheritance_attribute


        def ===(other)
          other.is_a? self
        end

        
        private
        
        def class_of_descendant(klass)
          if klass.superclass.superclass == Base
            klass
          else
            class_of_descendant(klass.superclass)
          end
        end
      end

      #
      # Initialize a new object. Send in attributes which
      # we'll dynamically set up read- and write methods for
      # and assign to instance variables. How read- and write 
      # methods are defined might change over time when the DSL
      # for describing column families and fields are in place
      # You can call initialize in multiple ways:
      #   ORMClass.new(attr_one: value, attr_two: value)
      #   ORMClass.new("the-id-of-the-new-record")
      #   ORMClass.new("the-id-of-the-new-record", attr_one: value, attr_two: value)
      #
      def initialize(*args)
        attributes = args.extract_options!
        id = args.first

        @new_record = true
        @destroyed = @readonly = false
        @relation_proxy_cache = {}

        self.attributes_raw = attributes_from_field_definition.merge('id' => id)
        self.attributes = attributes

        clear_dirty_states!

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
      #     column_family :base do
      #       field :name
      #     end
      #   end
      #
      #   person = Person.allocate
      #   person.init_with('attributes' => { 'name' => 'Alice' })
      #   person.name # => 'Alice'
      def init_with(coder)
        @new_record = false
        @destroyed = @readonly = false
        @relation_proxy_cache = {}

        self.attributes_raw = coder['attributes']
        fill_attributes_with_default_values_where_nil_is_not_allowed

        _run_find_callbacks
        _run_initialize_callbacks

        self
      end


      def ==(other)
        other.equal?(self) || other.instance_of?(self.class) && id == other.id
      end
      alias_method :eql?, :==

      def hash
        id.hash
      end

      def freeze
        @attributes.freeze
      end

      def frozen?
        @attributes.frozen?
      end


      def inspect
        attributes_as_string = known_attribute_names_for_inspect.collect do |attr_name|
          "#{attr_name}: #{attribute_for_inspect(attr_name)}"
        end.join(', ')

        "#<#{self.class} id: #{id.inspect}, #{attributes_as_string}>"
      end


      def id
        if read_attribute(:id).blank? && respond_to?(:default_id, true)
          @attributes["id"] = default_id
        end

        read_attribute(:id)
      end

      def id=(id)
        id = id.to_s unless id.blank?
        write_attribute(:id, id)
      end



      def readonly?
        !!@readonly
      end

      def readonly!
        @readonly = true
      end


      def clone
        object = self.class.new
        object.init_with('attributes' => attributes.select{|k| !['id', 'created_at', 'updated_at'].include?(k)})
        object
      end
      

      private

      #
      # A place to hook in if you need to add attributes
      # not known by the attribute schema in the inspect string.
      # Remember to include a call to super in your module so you
      # don't break the chain if you override it.
      # See Timestamps for an example
      #
      def known_attribute_names_for_inspect
        (self.class.known_attribute_names + (super rescue [])).uniq
      end

      def attribute_for_inspect(attr_name)
        value = read_attribute(attr_name)

        if value.is_a?(String) && value.length > 50
          "#{value[0..50]}...".inspect
        elsif value.is_a?(Date) || value.is_a?(Time)
          %("#{value.to_s}")
        else
          value.inspect
        end
      end


      def next_id
        IdFactory.next_for(self.class).to_s
      end
    end


    Base.class_eval do
      include Config
      include Persistence
      include Relations::Interface
      include Finders
      extend  RescueMissingTableOnFind
      include AttributeMethods
      include AttributeMethods::Write, AttributeMethods::Read
      include AttributeMethods::TimeZoneConversion
      include AttributeMethods::Dirty
      include Validations
      include Callbacks
      include Timestamps
      include SingleTableInheritance
      include DefaultId
      include QueryInstrumentation


      alias [] read_attribute
      alias []= write_attribute
    end
  end
end

require 'massive_record/orm/table'
require 'massive_record/orm/column'
require 'massive_record/orm/id_factory'
require 'massive_record/orm/log_subscriber'

ActiveSupport.run_load_hooks(:massive_record, MassiveRecord::ORM::Base)
