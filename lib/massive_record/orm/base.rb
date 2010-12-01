require 'active_model'
require 'massive_record/orm/validations'
require 'massive_record/orm/callbacks'

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
        assign_and_define_methods_for attributes
        _run_initialize_callbacks
      end

      # Initialize an empty model object from +coder+.  +coder+ must contain
      # the attributes necessary for initializing an empty model object.  For
      # example:
      #
      #   class Person < MassiveRecord::ORM::Table
      #   end
      #
      #   person = Person.allocate
      #   person.init_with('attributes' => { 'name' => 'Alice' })
      #   person.name # => 'Alice'
      def init_with(coder)
        assign_and_define_methods_for coder['attributes']
        _run_find_callbacks
        _run_initialize_callbacks
      end

      
      # Basic persistence methods - Needs to be implemented. Needed them
      # for wrapping callbacks around them. At least I think I need them now ;-)
      %w(save save! create create! destroy delete).each do |method|
        define_method(method) do
          true
        end
      end

      private

      def assign_and_define_methods_for(attributes)
        attributes.each do |attribute, value|
          class_eval { attr_accessor attribute }
          send("#{attribute}=", value)
        end
      end





      include ActiveModel::Translation
      include Validations
      include Callbacks
    end
  end
end

require 'massive_record/orm/table'
require 'massive_record/orm/column'
