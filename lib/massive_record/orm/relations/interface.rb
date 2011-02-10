module MassiveRecord
  module ORM
    module Relations
      module Interface
        extend ActiveSupport::Concern

        included do
          class_attribute :relations, :instance_writer => false
          self.relations = Set.new
        end


        module ClassMethods
          #
          # Used to define a references once relation. Example of usage:
          # 
          # class Person < MassiveRecord::ORM::Table
          #   column_family :info do
          #     field :name
          #   end
          #   
          #   references_one :boss, :class_name => "Person", :store_foreign_key_in => :info
          # end
          #
          # First argument is the name of the relation. class_name and foreign key is calculated from it, if none given.
          #
          # Options, all optional:
          #   <tt>class_name</tt>               Class name is calculated from name, but can be overridden here.
          #   <tt>foreign_key</tt>              Foreign key is calculated from name suffixed by _id as default.
          #   <tt>store_foreign_key_in</tt>::   Send in the column family to store foreign key in. If none given,
          #                                     you should define the foreign key method in class if it can be
          #                                     calculated from another attributes in your class.
          #   <tt>find_with</tt>                Assign it to a Proc and we will call it with the owner if you need complete
          #                                     control over how you retrieve your record.
          #                                     As a default TargetClass.find(foreign_key_method) is used.
          #
          def references_one(name, *args)
            metadata = Metadata.new(name, *args)
            metadata.relation_type = 'references_one'
            raise RelationAlreadyDefined unless self.relations.add?(metadata)
            create_references_one_accessors(metadata)
          end

          private


          def create_references_one_accessors(metadata)
            redefine_method(metadata.name) do
              relation_proxy(metadata.name).target
            end

            redefine_method(metadata.name+'=') do |record|
              relation_proxy(metadata.name).replace(record)
            end

            if metadata.persisting_foreign_key?
              add_field_to_column_family(metadata.store_foreign_key_in, metadata.foreign_key)
            end
          end
        end



        private

        def relation_proxy(name)
          name = name.to_s

          unless proxy = relation_proxy_get(name)
            if metadata = relations.find { |meta| meta.name == name }
              proxy = metadata.new_relation_proxy(self)
              relation_proxy_set(name, proxy)
            end
          end

          proxy
        end

        def relation_proxy_get(name)
          @relation_proxy_cache[name.to_s]
        end

        def relation_proxy_set(name, proxy)
          @relation_proxy_cache[name.to_s] = proxy
        end
      end
    end
  end
end
