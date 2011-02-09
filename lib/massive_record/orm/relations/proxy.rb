module MassiveRecord
  module ORM
    module Relations
      
      #
      # Parent class for all proxies sitting between records
      #
      class Proxy
        instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|inspect|to_s|extend|equal\?)$|^__|^respond_to|^should|^instance_variable_/ }

        attr_reader :target
        attr_accessor :owner, :metadata

        delegate :foreign_key, :store_foreign_key_in, :class_name, :name, :persisting_foreign_key?, :to => :metadata

        def initialize(options = {})
          options.to_options!
          self.owner = options[:owner]
          self.target = options[:target]
          self.metadata = options[:metadata]
        end


        def target=(target)
          @target = target
          loaded! unless @target.nil?
        end
        
        def load_target
          self.target = find_target if find_target?
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
            self.target = target
          end
        end



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

        #
        # Abstract method used to find target for the proxy.
        #
        def find_target
        end

        def find_target?
          !loaded?
        end
      end
    end
  end
end
