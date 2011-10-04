require 'massive_record/orm/persistence/operations/suppress'

require 'massive_record/orm/persistence/operations/insert'
require 'massive_record/orm/persistence/operations/update'
require 'massive_record/orm/persistence/operations/destroy'
require 'massive_record/orm/persistence/operations/reload'
require 'massive_record/orm/persistence/operations/atomic_operation'

require 'massive_record/orm/persistence/operations/embedded/insert'
require 'massive_record/orm/persistence/operations/embedded/update'
require 'massive_record/orm/persistence/operations/embedded/destroy'
require 'massive_record/orm/persistence/operations/embedded/reload'

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
          def suppress
            @suppressed = true
            yield
          ensure
            @suppressed = false
          end

          def suppressed?
            !!@suppressed
          end


          def insert(record, options = {})
            operator_for :insert, record, options
          end

          def update(record, options = {})
            operator_for :update, record, options
          end

          def destroy(record, options = {})
            operator_for :destroy, record, options
          end

          def atomic_operation(record, options = {})
            operator_for :atomic_operation, record, options
          end

          def reload(record, options = {})
            operator_for :reload, record, options
          end

          private
          
          def operator_for(operation, record, options)
            if suppressed?
              klass = Suppress
            else
              class_parts = [self]
              class_parts << "Embedded" if record.kind_of? ORM::Embedded
              class_parts << operation.to_s.classify

              klass = class_parts.join("::").constantize
            end

            klass.new(record, options)
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
