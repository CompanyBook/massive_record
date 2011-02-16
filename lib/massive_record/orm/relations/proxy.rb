module MassiveRecord
  module ORM
    module Relations
      #
      # Parent class for all proxies sitting between records.
      # It's responsibility is to transparently load and forward
      # method calls to it's target. Iy may also do some small maintenance
      # work like setting foreign key in owner object etc. That kind of
      # functionality is likely to be implemented in one of it's more
      # specific sub class proxies.
      #
      class Proxy
        instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|inspect|to_s|extend|equal\?)$|^__|^respond_to|^should|^instance_variable_/ }

        attr_reader :target
        attr_accessor :owner, :metadata

        delegate :foreign_key, :foreign_key_setter, :store_in, :store_foreign_key_in,
          :polymorphic_type_column, :polymorphic_type_column_setter,
          :class_name, :name, :persisting_foreign_key?, :find_with, :to => :metadata

        def initialize(options = {})
          options.to_options!
          self.metadata = options[:metadata]
          self.owner = options[:owner]
          self.target = options[:target]

          reset if target.nil?
        end


        #
        # The target of a relation is the record
        # the owner references. For instance,
        # 
        # class Person
        #   references_one :car
        # end
        #
        # The owner is a record of class person, the target will be the car.
        #
        def target=(target)
          @target = target
          loaded! unless @target.nil?
        end

        def target_class
          class_name.constantize
        end
        
        #
        # Returns the target. Loads it, if it's not there.
        # Returns nil if for some reason target could not be found.
        #
        def load_target
          self.target = find_target_or_find_with_proc if find_target?
          target
        rescue RecordNotFound
          reset
        end

        def reload
          reset
          load_target
        end

        def reset
          @loaded = @target = nil
        end

        def replace(target)
          if target.nil?
            reset 
          else
            raise_if_type_mismatch(target)
            self.target = target
          end
        end



        #
        # If the proxy is loaded it has a target
        #
        def loaded?
          !!@loaded
        end

        def loaded!
          @loaded = true
        end




        def respond_to?(*args)
          super || (load_target && target.respond_to?(*args))
        end

        def method_missing(method, *args, &block)
          return target.send(method, *args, &block) if load_target && target.respond_to?(method)
          super
        rescue NoMethodError => e
          raise e, e.message.sub(/ for #<.*$/, " via proxy for #{target}")
        end
      

        

        protected

        def find_target_or_find_with_proc
          find_with_proc? ? find_target_with_proc : find_target
        end

        #
        # "Abstract" method used to find target for the proxy.
        # Implement in subclasses. It is not called when the meta
        # data contains a find_with proc; in that case find_target_with_proc
        # is used instead
        #
        def find_target
        end
        
        #
        # Gives sub classes a place to hook into when we are
        # gonna find target(s) by the proc. For instance, the
        # references_many proxy ensures that the result of proc
        # is put inside of an array.
        #
        def find_target_with_proc
          find_with.call(owner)
        end

        #
        # When are we supposed to find a target? Find a target is done
        # through load_target.
        #
        def find_target?
          !loaded? && can_find_target?
        end

        #
        # Override this to controll when a target may be found.
        #
        def can_find_target?
          find_with_proc?
        end

        #
        # 
        #
        def find_with_proc?
          !find_with.nil? && find_with.respond_to?(:call)
        end

        def raise_if_type_mismatch(record)
          unless record.is_a? target_class
            message = "#{class_name}(##{target_class.object_id}) expected, got #{record.class}(##{record.class.object_id})"
            raise RelationTypeMismatch.new(message)
          end
        end
      end
    end
  end
end
