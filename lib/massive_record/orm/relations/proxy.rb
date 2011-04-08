module MassiveRecord
  module ORM
    module Relations
      #
      # Parent class for all proxies sitting between records.
      # It's responsibility is to transparently load and forward
      # method calls to it's proxy_target. Iy may also do some small maintenance
      # work like setting foreign key in proxy_owner object etc. That kind of
      # functionality is likely to be implemented in one of it's more
      # specific sub class proxies.
      #
      class Proxy
        instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|to_s|extend|equal\?)$|^__|^respond_to|^should|^instance_variable_/ }

        attr_reader :proxy_target
        attr_accessor :proxy_owner, :metadata

        delegate :class_name, :proxy_target_class, :represents_a_collection?, :to => :metadata

        def initialize(options = {})
          options.to_options!
          self.metadata = options[:metadata]
          self.proxy_owner = options[:proxy_owner]
          self.proxy_target = options[:proxy_target]

          reset if proxy_target.nil?
        end


        #
        # The proxy_target of a relation is the record
        # the proxy_owner references. For instance,
        # 
        # class Person
        #   references_one :car
        # end
        #
        # The proxy_owner is a record of class person, the proxy_target will be the car.
        #
        def proxy_target=(proxy_target)
          @proxy_target = proxy_target
          loaded! unless @proxy_target.nil?
        end
        
        #
        # Returns the proxy_target. Loads it, if it's not there.
        # Returns nil if for some reason proxy_target could not be found.
        #
        def load_proxy_target
          self.proxy_target = find_proxy_target_or_find_with_proc if find_proxy_target?
          proxy_target
        rescue RecordNotFound
          reset
        end

        def reload
          reset
          load_proxy_target
        end

        def reset
          @loaded = @proxy_target = nil
        end

        def replace(proxy_target)
          if proxy_target.nil?
            reset 
          else
            raise_if_type_mismatch(proxy_target)
            self.proxy_target = proxy_target
          end
        end

        def inspect
          load_proxy_target.inspect
        end



        #
        # If the proxy is loaded it has a proxy_target
        #
        def loaded?
          !!@loaded
        end

        def loaded!
          @loaded = true
        end




        def respond_to?(*args)
          super || (load_proxy_target && proxy_target.respond_to?(*args))
        end

        def method_missing(method, *args, &block)
          return proxy_target.send(method, *args, &block) if load_proxy_target && proxy_target.respond_to?(method)
          super
        rescue NoMethodError => e
          raise e, e.message.sub(/ for #<.*$/, " via proxy for #{proxy_target}")
        end
      

        # Strange.. Without Rails, to_param goes through method_missing,
        #           With Rails it seems like the proxy answered to to_param, which
        #           kinda was not what I wanted.
        def to_param # :nodoc:
          proxy_target.try :to_param
        end
        

        protected

        def find_proxy_target_or_find_with_proc
          find_with_proc? ? find_proxy_target_with_proc : find_proxy_target
        end

        #
        # "Abstract" method used to find proxy_target for the proxy.
        # Implement in subclasses. It is not called when the meta
        # data contains a find_with proc; in that case find_proxy_target_with_proc
        # is used instead
        #
        def find_proxy_target
        end
        
        #
        # Gives sub classes a place to hook into when we are
        # gonna find proxy_target(s) by the proc. For instance, the
        # references_many proxy ensures that the result of proc
        # is put inside of an array.
        #
        def find_proxy_target_with_proc(options = {})
          metadata.find_with.call(proxy_owner, options)
        end

        #
        # When are we supposed to find a proxy_target? Find a proxy_target is done
        # through load_proxy_target.
        #
        def find_proxy_target?
          !loaded? && can_find_proxy_target?
        end

        #
        # Override this to controll when a proxy_target may be found.
        #
        def can_find_proxy_target?
          find_with_proc?
        end

        def update_foreign_key_fields_in_proxy_owner?
          !proxy_owner.destroyed?
        end

        #
        # Are we supposed to find proxy_target with a proc?
        #
        def find_with_proc?
          !metadata.find_with.nil? && metadata.find_with.respond_to?(:call)
        end

        def raise_if_type_mismatch(record)
          unless record.is_a? proxy_target_class
            message = "#{class_name}(##{proxy_target_class.object_id}) expected, got #{record.class}(##{record.class.object_id})"
            raise RelationTypeMismatch.new(message)
          end
        end
      end
    end
  end
end
