module MassiveRecord
  module ORM
    module Validations
      extend ActiveSupport::Concern
      include ActiveModel::Validations


      def save(options = {})
        perform_validation(options) ? super : false
      end


      private

      def perform_validation(options = {})
        perform_validation = options[:validate] != false
        perform_validation ? valid? : true
      end
    end
  end
end
