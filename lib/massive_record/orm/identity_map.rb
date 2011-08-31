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

      class << self
        #
        # Switch to either turn on or off the identity map
        #
        def enabled=(boolean)
          Thread.current[:identity_map_enabled] = !!boolean
        end

        def enabled
          Thread.current[:identity_map_enabled]
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



        def get(klass, id)
          repository[class_to_repository_key(klass)][id]
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

        def repository
          Thread.current[:identity_map_repository] ||= Hash.new { |hash, key| hash[key] = {} }
        end

        def record_class_to_repository_key(record)
          class_to_repository_key record.class
        end

        def class_to_repository_key(klass)
          klass.to_s
        end
      end





      module ClassMethods
        private


        def find_one(id, option)
          IdentityMap.get(self, id) || IdentityMap.add(super)
        end
      end
    end
  end
end
