module MassiveRecord
  module ORM
    module Config
      extend ActiveSupport::Concern 
      
      module ClassMethods
        # TODO  To be changed..
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
      end
    end
  end
end
