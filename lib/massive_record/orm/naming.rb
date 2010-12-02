module MassiveRecord
  module ORM
    module Naming
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def table_name
          @table_name ||= self.to_s.demodulize.underscore.pluralize
        end
      end
      
    end
  end
end
