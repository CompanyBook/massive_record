module MassiveRecord
  module ORM
    module Finders

      #
      # A finder scope's jobs is to contain and build up
      # limitations and meta data of a DB query about to being
      # executed, allowing us to call for instance
      #
      # User.select(:info).limit(5) or
      # User.select(:info).find(a_user_id)
      #
      # Each call adds restrictions or info about the query about
      # to be executed, and the proxy will act as an Enumerable object
      # when asking for multiple values
      #
      class Scope
        MULTI_VALUE_METHODS = %w(select)
        SINGLE_VALUE_METHODS = %w(limit)
        
        attr_accessor *MULTI_VALUE_METHODS.collect { |m| m + "_values" }
        attr_accessor *SINGLE_VALUE_METHODS.collect { |m| m + "_value" }



        def initialize
          reset_single_values_methods
          reset_multi_values_methods
        end
        



        def select(*select)
          self.select_values = (self.select_values + select.flatten).compact.uniq
          self
        end




        def limit(limit)
          self.limit_value = limit
          self
        end




        private

        def reset_single_values_methods
          SINGLE_VALUE_METHODS.each { |m| instance_variable_set("@#{m}_value", nil) } 
        end

        def reset_multi_values_methods
          MULTI_VALUE_METHODS.each { |m| instance_variable_set("@#{m}_values", []) } 
        end
      end
    end
  end
end
