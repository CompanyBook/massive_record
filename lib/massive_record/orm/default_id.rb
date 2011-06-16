module MassiveRecord
  module ORM
    module DefaultId
      extend ActiveSupport::Concern

      included do
        before_create :ensure_record_has_id, :if => :auto_increment_id
      end


      module InstanceMethods
        private

        def ensure_record_has_id
          self.id = next_id if id.blank?
        end
      end
    end
  end
end
