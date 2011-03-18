module MassiveRecord
  module ORM
    module SingleTableInheritance
      extend ActiveSupport::Concern

      included do
        after_initialize :ensure_proper_type

        
      end

      def ensure_proper_type
        attr = self.class.inheritance_attribute

        if respond_to?(attr) && self[attr].blank? && self.class.base_class != self.class
          self[attr] = self.class.to_s
        end
      end
    end
  end
end
