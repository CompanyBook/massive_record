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
        attr_accessor :loaded, :klass
        alias :loaded? :loaded


        delegate :to_xml, :to_yaml, :length, :collect, :map, :each, :all?, :include?, :to => :to_a
        

        def initialize(klass)
          @klass = klass
          @extra_finder_options = {}

          reset
          reset_single_values_options
          reset_multi_values_options
        end
        
        
        def reset
          @loaded = false
        end



        #
        # Multi value options
        #

        def select(*select)
          self.select_values |= select.flatten.compact.collect(&:to_s)
          self
        end


        #
        # Single value options
        #

        def limit(limit)
          self.limit_value = limit
          self
        end





        def ==(other)
          case other
          when Scope
            object_id == other.object_id
          when Array
            to_a == other
          else
            raise "Don't know how to compare #{self.class} with #{other.class}"
          end
        end


        def first(options = {})
          return @records.first if loaded?

          apply_extra_finder_options(options)
          limit(1).to_a.first
        end

        def to_a
          return @records if loaded?
          load_records
        end

        def all(options = {})
          apply_extra_finder_options(options)
          to_a
        end


        private


        def load_records
          @records = klass.find(:all, find_options)
          @loaded = true
          @records
        end

        def find_options
          options = {}

          SINGLE_VALUE_METHODS.each do |m|
            value = send("#{m}_value") and options[m.to_sym] = value
          end

          MULTI_VALUE_METHODS.each do |m|
            values = send("#{m}_values") and values.any? and options[m.to_sym] = values
          end

          options.merge(@extra_finder_options)
        end



        def apply_extra_finder_options(options)
          @extra_finder_options.merge! options
        end



        def reset_single_values_options
          SINGLE_VALUE_METHODS.each { |m| instance_variable_set("@#{m}_value", nil) } 
        end

        def reset_multi_values_options
          MULTI_VALUE_METHODS.each { |m| instance_variable_set("@#{m}_values", []) } 
        end
      end
    end
  end
end
