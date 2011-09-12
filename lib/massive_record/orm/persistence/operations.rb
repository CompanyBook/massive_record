require 'massive_record/orm/persistence/operations/insert'
require 'massive_record/orm/persistence/operations/update'
require 'massive_record/orm/persistence/operations/destroy'
require 'massive_record/orm/persistence/operations/atomic_operation'

module MassiveRecord
  module ORM
    module Persistence

      #
      # The persistence Operations are in charge of inserting,
      # updating and destroying records.
      #
      # It's reason for even existing is that we need to
      # do these operations differently based on if we are
      # saving a record which has a Table as it's class or saving
      # an embedded record.
      #
      # The Persistence module will call upon
      # Operations.insert(record, options) and execute on the returned
      # object. Based on what kind of record we are getting in we
      # can determine what kind of Operation object to return
      #
      module Operations
        class << self
          def insert(record, options = {})
            Insert.new(record, options)
          end

          def update(record, options = {})
            Update.new(record, options)
          end

          def destroy(record, options = {})
            Destroy.new(record, options)
          end

          def atomic_operation(record, options = {})
            AtomicOperation.new(record, options)
          end
        end


        attr_reader :record, :klass, :options


        def initialize(record, options = {})
          @record = record
          @klass = record.class
          @options = options
        end


        def execute
          raise "Not implemented"
        end
      end
    end
  end
end
