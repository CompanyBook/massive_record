module MassiveRecord
  module ORM
    module Finders
      extend ActiveSupport::Concern

      module ClassMethods
        #
        # Just a dummy version of this to make callbacks work
        #
        def find(*args)
          raise ArgumentError.new("At least one argument required!") if args.empty?
          
          instantiate({:id => args[0]}.merge(args[1] || {}))
        end

        def first(*args)
          find(:first, *args)
        end

        def last(*args)
          find(:last, *args)
        end

        def all(*args)
          find(:all, *args)
        end

        private

        def instantiate(record)
          allocate.tap do |model|
            model.init_with('attributes' => record)
          end
        end
      end
    end
  end
end
