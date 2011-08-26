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
    class IdentityMap
      class << self
        def enabled=(boolean)
          Thread.current[:identity_map_enabled] = !!boolean
        end

        def enabled
          Thread.current[:identity_map_enabled]
        end
        alias enabled? enabled


        def repository
          Thread.current[:identity_map_repository] ||= Hash.new { |hash, key| hash[key] = {} }
        end
        delegate :clear, :to => :repository


        def get(klass, id)
          repository[class_to_repository_key(klass)][id]
        end

        def add(record)
          repository[record_class_to_repository_key(record)][record.id] = record
        end

        def remove(record)
          repository[record_class_to_repository_key(record)].delete record.id
        end



        private

        def record_class_to_repository_key(record)
          class_to_repository_key record.class
        end

        def class_to_repository_key(klass)
          klass.to_s
        end
      end
    end
  end
end
