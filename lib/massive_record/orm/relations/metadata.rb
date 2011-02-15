module MassiveRecord
  module ORM
    module Relations

      #
      # The master of metadata related to a relation. For instance;
      # references_one :employee, :foreign_key => "person_id", :class_name => "Person"
      #
      class Metadata
        attr_writer :foreign_key, :store_in, :class_name, :name, :relation_type, :polymorphic
        attr_accessor :find_with
        
        def initialize(name, options = {})
          options.to_options!
          self.name = name
          self.foreign_key = options[:foreign_key]
          if options.has_key? :store_in
            self.store_in = options[:store_in]
          elsif options.has_key? :store_foreign_key_in
            self.store_foreign_key_in = options[:store_foreign_key_in]
          end
          self.class_name = options[:class_name]
          self.find_with = options[:find_with]
          self.polymorphic = options[:polymorphic]
        end


        def name
          @name.to_s if @name
        end

        def relation_type
          if @relation_type
            relation_type = @relation_type.to_s
            relation_type += "_polymorphic" if polymorphic?
            relation_type
          end
        end

        def foreign_key
          (@foreign_key || calculate_foreign_key).to_s
        end

        def foreign_key_setter
          foreign_key+'='
        end

        def polymorphic_type_column
          type_column = foreign_key.gsub(/_id$/, '')
          type_column + "_type"
        end

        def polymorphic_type_column_setter
          polymorphic_type_column+'='
        end

        def class_name
          (@class_name || calculate_class_name).to_s
        end


        def store_in
          @store_in.to_s if @store_in
        end

        def store_foreign_key_in
          ActiveSupport::Deprecation.warn("store_foreign_key_in is deprecated. Use store_in instead!")
          store_in
        end

        def store_foreign_key_in=(column_family)
          ActiveSupport::Deprecation.warn("store_foreign_key_in is deprecated. Use store_in instead!")
          self.store_in = column_family
        end

        def persisting_foreign_key?
          !!store_in
        end


        def polymorphic
          !!@polymorphic
        end

        def polymorphic?
          polymorphic
        end


        def new_relation_proxy(owner)
          proxy_class_name.constantize.new(:owner => owner, :metadata => self)
        end

        
        def ==(other)
          other.instance_of?(self.class) && other.hash == hash
        end
        alias_method :eql?, :==

        def hash
          name.hash
        end



        def represents_a_collection?
          relation_type == 'references_many'
        end




        private


        def calculate_class_name
          name.to_s.classify
        end

        def calculate_foreign_key
          fk = name.downcase + "_id"
          fk += "s" if represents_a_collection?
          fk
        end

        def proxy_class_name
          "MassiveRecord::ORM::Relations::Proxy::"+relation_type.classify
        end
      end
    end
  end
end
