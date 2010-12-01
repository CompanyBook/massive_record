module MassiveRecord
  module ORM
    module Callbacks
      extend ActiveSupport::Concern

      CALLBACKS = [
        :after_initialize, :after_find, #:after_touch, 
        :before_validation, :after_validation,
        :before_save, :around_save, :after_save,
        :before_create, :around_create, :after_create,
        #:before_update, :around_update, :after_update,
        #:before_destroy, :around_destroy, :after_destroy
      ]

      included do
        extend ActiveModel::Callbacks
        include ActiveModel::Validations::Callbacks

        define_model_callbacks :initialize, :find, :only => :after
        define_model_callbacks :save, :create
      end




      private

      def create_or_update
        _run_save_callbacks { super }
      end

      def create
        _run_create_callbacks { super }
      end 
    end
  end
end
