module MassiveRecord
  module ORM
    module Naming
      extend ActiveSupport::Concern 
      
      module ClassMethods
        def table_name
          @table_name ||= self.to_s.demodulize.underscore.pluralize
        end
      end
    end
  end
end
