module MassiveRecord
  module ORM
    module Relations

      #
      # The master of metadata related to a relation. For instance;
      # references_one :employee, :foreign_key => "person_id", :class_name => "Person"
      #
      class Metadata
        extend ActiveSupport::Memoizable
        
        attr_writer :foreign_key, :class_name, :name

        
        def initialize(name, options = {})
          options.to_options!
          self.name = name
          self.foreign_key = options[:foreign_key]
          self.class_name = options[:class_name]
        end


        def name
          @name.to_s
        end

        def foreign_key
          (@foreign_key || calculate_foreign_key).to_s
        end
        memoize :foreign_key

        def class_name
          (@class_name || calculate_class_name).to_s
        end
        memoize :class_name



        
        def ==(other)
          other.instance_of?(self.class) && other.hash == hash
        end
        alias_method :eql?, :==

        def hash
          name.hash
        end


        private


        def calculate_class_name
          name.to_s.classify
        end

        def calculate_foreign_key
          class_name.downcase + "_id"
        end
      end
    end
  end
end
