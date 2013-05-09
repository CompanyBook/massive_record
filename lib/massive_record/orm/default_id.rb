module MassiveRecord
  module ORM
    module DefaultId
      extend ActiveSupport::Concern

      included do
        before_create :ensure_record_has_id, :if => :set_id_from_factory_before_create
      end


      private

      def ensure_record_has_id
        self.id = next_id if id.blank?
      end
    end
  end
end
