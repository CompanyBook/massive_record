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

          type = args.shift if args.first.is_a? Symbol

          attributes =  if type
                          table.send(type, *args)
                        else
                          table.find(*args)
                        end

          instantiate(attributes)
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

        # TODO  To be removed
        #
        #       Only put. in place to make it possible for find(:first) etc
        #       to be testable right now. It should return a real wrapper
        #       table (and quit possibly be removed into it's own module
        #       which handles connection and tables etc)
        #
        #       ..oh, another thing. I think we in find method above will have
        #       to call attributes.columns to retrieve the attributes as this
        #       table.find returns now right away.
        def table
          @table ||= MassiveRecord::Wrapper::Table.new(nil, nil).tap do |t|
            def t.find(*args)
              {:id => args[0]}.merge(args[1] || {})
            end
          end
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
