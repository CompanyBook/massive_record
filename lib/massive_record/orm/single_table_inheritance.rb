module MassiveRecord
  module ORM
    module SingleTableInheritance
      extend ActiveSupport::Concern

      included do
        after_initialize :ensure_proper_type

        
      end

      def ensure_proper_type
        if respond_to?(self.class.inheritance_attribute) && self[self.class.inheritance_attribute].blank?
          self[self.class.inheritance_attribute] = self.class.to_s
        end
      end
    end
  end
end
