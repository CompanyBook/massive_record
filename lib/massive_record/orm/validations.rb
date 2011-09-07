module MassiveRecord
  module ORM

    # 
    # Raised when save! or create! fails due to invalid record
    # A rescued error contains record which you can read errors
    # from as normal
    #
    class RecordInvalid < MassiveRecordError
      attr_reader :record
      def initialize(record)
        @record = record
        errors = @record.errors.full_messages.join(", ")
        super(I18n.t("activemodel.errors.messages.record_invalid", :errors => errors))
      end
    end




    module Validations
      extend ActiveSupport::Concern
      include ActiveModel::Validations


      module ClassMethods
        def create!(*args)
          record = new(*args)
          record.save!
          record
        end
      end


      def save(options = {})
        perform_validation(options) ? super : false
      end

      def save!(options = {})
        perform_validation(options) ? super : raise(RecordInvalid.new(self))
      end


      private

      def perform_validation(options = {})
        perform_validation = options[:validate] != false
        perform_validation ? valid? : true
      end
    end
  end
end
