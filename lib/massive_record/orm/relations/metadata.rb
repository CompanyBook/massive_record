module MassiveRecord
  module ORM
    module Relations

      #
      # The master of metadata related to a relation. For instance;
      # references_one :employee, :foreign_key => "person_id", :class_name => "Person"
      #
      # TODO
      #   * We need a way to supply custom finder method, so that proxy's find_target uses
      #     some custom loading in cases we want to start scan from given key for instance.
      #
      #
      class Metadata
        attr_writer :foreign_key, :store_foreign_key_in, :class_name, :name, :relation_type
        
        def initialize(name, options = {})
          options.to_options!
          self.name = name
          self.foreign_key = options[:foreign_key]
          self.store_foreign_key_in = options[:store_foreign_key_in]
          self.class_name = options[:class_name]
        end


        def name
          @name.to_s if @name
        end

        def relation_type
          @relation_type.to_s if @relation_type
        end

        def foreign_key
          (@foreign_key || calculate_foreign_key).to_s
        end

        def class_name
          (@class_name || calculate_class_name).to_s
        end


        def store_foreign_key_in
          @store_foreign_key_in.to_s if @store_foreign_key_in
        end

        def persisting_foreign_key?
          !!store_foreign_key_in
        end


        def new_relation_proxy(owner)
          Proxy.new(:owner => owner, :metadata => self)
        end

        
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
          name.downcase + "_id"
        end
      end
    end
  end
end
