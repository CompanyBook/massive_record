module MassiveRecord
  module ORM
    module Callbacks
      extend ActiveSupport::Concern

      CALLBACKS = [
        :after_initialize ,:after_find#, :after_touch, :before_validation, :after_validation,
        #:before_save, :around_save, :after_save, :before_create, :around_create,
        #:after_create, :before_update, :around_update, :after_update,
        #:before_destroy, :around_destroy, :after_destroy, :after_commit, :after_rollback
      ]

      included do
        extend ActiveModel::Callbacks
        include ActiveModel::Validations::Callbacks

        define_model_callbacks :initialize, :find, :only => :after
      end
    end
  end
end
