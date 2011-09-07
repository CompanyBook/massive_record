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
        SINGLE_VALUE_METHODS = %w(limit starts_with offset)
        
        attr_accessor *MULTI_VALUE_METHODS.collect { |m| m + "_values" }
        attr_accessor *SINGLE_VALUE_METHODS.collect { |m| m + "_value" }
        attr_accessor :loaded, :klass, :extra_finder_options
        alias :loaded? :loaded


        delegate :to_xml, :to_yaml, :length, :size, :collect, :map, :each, :all?, :include?, :to => :to_a
        

        def initialize(klass)
          @klass = klass
          @extra_finder_options = {}

          reset
          reset_single_values_options
          reset_multi_values_options
        end

        def initialize_copy(old)
          reset
        end
        

        def reset
          @loaded = false
          @records = []
        end



        #
        # Multi value options
        #

        def select(*select)
          cloned_version_with { self.select_values |= select.flatten.compact.collect(&:to_s) }
        end


        #
        # Single value options
        #

        def limit(limit)
          cloned_version_with { self.limit_value = limit }
        end

        def starts_with(starts_with)
          cloned_version_with { self.starts_with_value = starts_with }
        end

        def offset(offset)
          cloned_version_with { self.offset_value = offset }
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



        def find(*args)
          options = args.extract_options!.to_options
          
          if options.any?
            apply_finder_options(options).find(*args)
          else
            klass.do_find(*args << find_options)
          end
        end

        def all(options = {})
          if options.empty?
            to_a
          else
            apply_finder_options(options).to_a
          end
        end

        def first(options = {})
          if loaded? && options.empty?
            @records.first
          else
            apply_finder_options(options).limit(1).to_a.first
          end
        end

        def last(*args)
          raise "Sorry, but query last requires all records to be fetched. If you really want to do this, do an scope.all.last instead."
        end



        def to_a
          return @records if loaded?
          @records = load_records
          @records = [@records] unless @records.is_a? Array
          @records
        end

        
        #
        # Takes a hash of finder options, applies them to
        # a new scope and returns a that scope.
        #
        def apply_finder_options(options)
          scope = clone
          return scope if options.empty?

          options.each do |scope_method, arguments|
            if respond_to? scope_method
              scope = scope.send(scope_method, arguments)
            else
              scope.extra_finder_options[scope_method] = arguments              
            end
          end

          scope
        end


        private

        def cloned_version_with(&block)
          clone.tap { |scope| scope.instance_eval(&block) }
        end

        def load_records
          @records = klass.do_find(:all, find_options)
          @loaded = true
          @records
        end

        # Returns find options which adapter's find understands.
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
