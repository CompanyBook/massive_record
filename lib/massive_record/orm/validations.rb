module MassiveRecord
  module ORM
    module Validations
      extend ActiveSupport::Concern
      include ActiveModel::Validations


      def save
        valid? ? super : false
      end
    end
  end
end
