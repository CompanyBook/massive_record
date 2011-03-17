module MassiveRecord
  module ORM
    module SingleTableInheritance
      extend ActiveSupport::Concern

      included do

      end


      module ClassMethods
        
        def base_class
          class_of_descendant(self)
        end

        private

        def class_of_descendant(klass)
          if klass.superclass.superclass == Base
            klass
          else
            class_of_descendant(klass.superclass)
          end
        end
      end
    end
  end
end
