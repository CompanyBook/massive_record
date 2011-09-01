module MassiveRecord
  module ORM

    #
    # The goal of the IdentiyMap is to make sure that the same object is not loaded twice
    # from the database, but uses the same object if you do 2.times { AClass.find(1) }.
    #
    # To get a quick introduction on IdentityMap see: http://www.martinfowler.com/eaaCatalog/identityMap.html
    #
    # You can enable / disable Identity map by doing:
    # MassiveRecord::ORM::IdentityMap.enabled = flag
    #
    module IdentityMap
      extend ActiveSupport::Concern

      #
      # Error is raised internally of the identity map to signal that
      # you tried to get a record from a parent class, but you looked
      # it up via it's sub class. For instance A is a super class of B.
      # IdentityMap.get(B, "id-belonging-to-an-A-class") will raise the
      # error.
      #
      # This error will however not "leak" outside of the identity map's
      # code. It should be handled internally, and the goal for it is just
      # not to hit the database more than we need to if we know that the
      # database will return nil as well.
      #
      class RecordIsSuperClassOfQueriedClass < MassiveRecordError; end

      class << self
        #
        # Switch to either turn on or off the identity map
        #
        def enabled=(boolean)
          Thread.current[:identity_map_enabled] = boolean
        end

        def enabled
          !!Thread.current[:identity_map_enabled]
        end
        alias enabled? enabled


        #
        # Call this with a block to ensure that IdentityMap is enabled
        # for that block and reset to it's origianl setting thereafter
        #
        def use
          original_value, self.enabled = enabled, true
          yield
        ensure
          self.enabled = original_value
        end

        #
        # Call this with a block to ensure that IdentityMap is disabled
        # for that block and reset to it's origianl setting thereafter
        #
        def without
          original_value, self.enabled = enabled, false
          yield
        ensure
          self.enabled = original_value
        end



        def get(klass, *ids)
          get_many = ids.first.is_a?(Array)

          ids.flatten!

          result =  case ids.length
                    when 0
                      raise ArgumentError.new("Must have at least one ID!")
                    when 1
                      result = get_one(klass, ids.first)
                      get_many ? [result].compact : result
                    else
                      get_some(klass, ids)
                    end

          if records = Array(result).compact and records.any?
            ActiveSupport::Notifications.instrument("identity_map.massive_record", {
              :name => [klass, 'loaded from identity map'].join(' '),
              :records => records
            }) do
              result
            end
          end

          result
        end

        def add(record)
          return if record.nil?

          repository[record_class_to_repository_key(record)][record.id] = record
        end

        def remove(record)
          remove_by_id record.class, record.id
        end

        def remove_by_id(klass, id)
          repository[class_to_repository_key(klass)].delete id
        end

        delegate :clear, :to => :repository



        private

        def get_one(klass, id)
          if record = repository[class_to_repository_key(klass)][id]
            if klass == record.class || klass.descendants.include?(record.class)
              record
            else
              raise RecordIsSuperClassOfQueriedClass.new("#{record.class} is a super class of #{klass}. Please look your #{klass}-record up by do a #{klass}.find(#{record.id.inspect})")
            end
          end
        end

        def get_some(klass, ids)
          ids.collect do |id|
            begin
              get_one(klass, id)
            rescue RecordIsSuperClassOfQueriedClass
              nil
            end
          end.compact
        end

        def repository
          Thread.current[:identity_map_repository] ||= Hash.new { |hash, key| hash[key] = {} }
        end

        def record_class_to_repository_key(record)
          class_to_repository_key record.class
        end

        def class_to_repository_key(klass)
          klass.base_class
        end
      end





      module ClassMethods
        private


        def find_one(id, options)
          return super unless IdentityMap.enabled? && can_use_identity_map_with?(options)

          IdentityMap.get(self, id) || IdentityMap.add(super)
        rescue RecordIsSuperClassOfQueriedClass
          nil
        end

        def find_some(ids, options)
          return super unless IdentityMap.enabled? && can_use_identity_map_with?(options)

          records_from_database = []
          records_from_identity_map = IdentityMap.get(self, ids)

          missing_ids = ids - records_from_identity_map.collect(&:id)

          if missing_ids.any?
            records_from_database = super(missing_ids, options)
            records_from_database.each { |record| IdentityMap.add(record) }
          end

          records_from_identity_map | records_from_database
        end



        def can_use_identity_map_with?(finder_options)
          !finder_options.has_key?(:select)
        end
      end



      module InstanceMethods
        def reload
          IdentityMap.remove(self) if IdentityMap.enabled?
          super
        end

        def destroy
          return super unless IdentityMap.enabled?

          super.tap { IdentityMap.remove(self) }
        end
        alias_method :delete, :destroy

        private


        def create
          return super unless IdentityMap.enabled?

          super.tap { IdentityMap.add(self) }
        end
      end




      class Middleware
        class BodyProxy
          def initialize(target, original_identity_map_state)
            @target = target
            @original_identity_map_state = original_identity_map_state
          end

          def each(&block)
            @target.each(&block)
          end

          def close
            @target.close if @target.respond_to?(:close)
          ensure
            IdentityMap.enabled = @original_identity_map_state
            IdentityMap.clear
          end
          
        end



        def initialize(app)
          @app = app
        end

        def call(env)
          original_identity_map_state = IdentityMap.enabled?
          IdentityMap.enabled = true

          status, headers, body = @app.call(env)
          [status, headers, BodyProxy.new(body, original_identity_map_state)]
        end
      end
    end
  end
end
