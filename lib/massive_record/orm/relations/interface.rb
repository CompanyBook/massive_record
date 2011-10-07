module MassiveRecord
  module ORM
    module Relations
      module Interface
        extend ActiveSupport::Concern

        included do
          class_attribute :relations, :instance_writer => false
          self.relations = nil
        end


        module ClassMethods
          #
          # Used to define a references one relation. Example of usage:
          # 
          # class Person < MassiveRecord::ORM::Table
          #   column_family :info do
          #     field :name
          #   end
          #   
          #   references_one :boss, :class_name => "Person", :store_in => :info
          # end
          #
          # First argument is the name of the relation. class_name and foreign key is calculated from it, if none given.
          #
          #
          # Options, all optional:
          #
          #   <tt>class_name</tt>::   Class name is calculated from name, but can be overridden here.
          #   <tt>polymorphic</tt>::  Set it to true for make the association polymorphic. Will use foreign_key,
          #                           remove the "_id" (if it's there) and add _type for it's reading/writing of type.
          #   <tt>foreign_key</tt>::  Foreign key is calculated from name suffixed by _id as default.
          #   <tt>store_in</tt>::     Send in the column family to store foreign key in. If none given,
          #                           you should define the foreign key method in class if it can be
          #                           calculated from another attributes in your class.
          #   <tt>find_with</tt>::    Assign it to a Proc and we will call it with the proxy_owner if you need complete
          #                           control over how you retrieve your record.
          #                           As a default TargetClass.find(foreign_key_method) is used.
          #
          def references_one(name, *args)
            metadata = set_up_relation('references_one', name, *args)

            create_references_one_accessors(metadata)
            create_references_one_polymorphic_accessors(metadata) if metadata.polymorphic?
          end


          #
          # Used to define a reference many relation. Example of usage:
          # 
          # class Person < MassiveRecord::ORM::Table
          #   column_family :info do
          #     field :name
          #   end
          #   
          #   references_many :cars, :store_in => :info
          # end
          #
          # First argument is the name of the relation. class_name and attribute for foreign keys are calculated from it,
          # if noen given. In the example above Person records will have attribute cars_ids which will be
          # an array populated with foreign keys.
          #
          #
          # Options, all optional:
          #
          #   <tt>class_name</tt>::            Class name is calculated from name, but can be overridden here.
          #   <tt>foreign_key</tt>::           Foreign key is calculated from name suffixed by _ids as default.
          #   <tt>store_in</tt>::              Send in the column family to store foreign key in. If none given,
          #                                    you should define the foreign key method in class if it can be
          #                                    calculated from another attributes in your class.
          #   <tt>records_starts_from</tt>::   A method name which returns an ID to start from when fetching rows in
          #                                    Person's table. This is useful if you for instance has a person with id 1
          #                                    and in your table for cars have cars id like "<person_id>-<incremental number>"
          #                                    or something. Then you can say references_many :cars, :starts_with => :id.
          #   <tt>find_with</tt>::             Assign it to a Proc and we will call it with the proxy_owner if you need complete
          #                                    control over how you retrieve your record.
          #                                    As a default TargetClass.find(foreign_keys_method) is used.
          #
          #
          # Example usage:
          #
          # person = Person.first
          # person.cars               # loads and returns all cars.
          # person.cars.first         # Returns first car, either by loading just one object, or return first object in loaded proxy.
          # person.cars.find("an_id") # Tries to load car with id 1 if that id is among person's cars. Either by a query and look among loaded records
          # person.cars.limit(3)      # Returns the 3 first cars, either by slice the loaded array of cars, or do a limited DB query.
          #
          #
          def references_many(name, *args)
            metadata = set_up_relation('references_many', name, *args)
            create_references_many_accessors(metadata)
          end



          #
          # Used to defined a relationship to other models where the other models are embedded inside of owner record.
          #
          # class Person < MassiveRecord::ORM::Table
          #   embeds_many :addresses
          # end
          #
          #
          # The embeds many association gets one column family per association. embeds_many :addresses
          # will by default be stored in the addresses column family. You can however do this:
          # embeds_many :addresses, :store_in => :base to manipulate the column family it is stored within.
          #
          # Embedded records gets a composite key consisting of base_class and the record's id. This is how
          # it is possible to mix embedded collection in to one column family / existing family with "normal" attributes.
          # Please mind however, doing such a mixing might get you into trouble if you have attribute names which looks
          # like an embedded address key. Companybook wanted this option, as they said haveing multiple column family might
          # slow down Hbase.
          #
          # Attributes will be serialized by the Base.coder, by default will be JSON, but it really can be anything.
          # The way records are stored inside of a column family will be:
          #
          # | key           | attributes                                        |
          # ---------------------------------------------------------------------
          # | "address|id1" | { :street => "Askerveien", :number => "12", etc... }
          #
          #
          #
          # Options, all optional:
          #
          #   <tt>class_name</tt>::            Class name is calculated from name, but can be overridden here.
          #   <tt>store_in</tt>::              Send in the column family to store foreign key in. If none given,
          #
          def embeds_many(name, *args)
            metadata = set_up_relation('embeds_many', name, *args)
            metadata.owner_class = self
            add_column_family(metadata.store_in)
            create_embeds_many_accessors(metadata)
          end



          #
          # Embedded in is being used together with embeds_many on the other side
          # of such a relation.
          #
          # class Address < MassiveRecord::ORM::Embedded
          #   embedded_in :person
          # end
          #
          # You can also pass in :polymorphic => true as an option. If you do so here is an example:
          #
          #   class Person < MassiveRecord::ORM::Table
          #     embeds_many :addresses, :inverse_of => :addressable
          #   end
          #   
          #   class Address < MassiveRecord::ORM::Embedded
          #     embedded_in :addressable, :inverse_of => :addresses, :polymorphic => true
          #   end
          #
          def embedded_in(name, *args)
            metadata = set_up_relation('embedded_in', name, *args)
            metadata.owner_class = self
            create_embedded_in_accessors(metadata)
          end


          private

          def set_up_relation(type, name, *args)
            ensure_relations_exists

            Metadata.new(name, *args).tap do |metadata|
              metadata.relation_type = type
              raise RelationAlreadyDefined unless self.relations.add?(metadata)
            end
          end

          def ensure_relations_exists
            self.relations = Set.new if relations.nil?
          end


          def create_references_one_accessors(metadata)
            redefine_method(metadata.name) do
              proxy = relation_proxy(metadata.name)
              proxy.load_proxy_target ? proxy : nil
            end

            redefine_method(metadata.name+'=') do |record|
              relation_proxy(metadata.name).replace(record)
            end

            if metadata.persisting_foreign_key?
              add_field_to_column_family(metadata.store_in, metadata.foreign_key)
            end
          end

          def create_references_one_polymorphic_accessors(metadata)
            if metadata.persisting_foreign_key?
              add_field_to_column_family(metadata.store_in, metadata.polymorphic_type_column)
            end
          end

          def create_references_many_accessors(metadata)
            redefine_method(metadata.name) do
              relation_proxy(metadata.name)
            end

            redefine_method(metadata.name+'=') do |records|
              relation_proxy(metadata.name).replace(records)
            end

            if metadata.persisting_foreign_key?
              add_field_to_column_family(metadata.store_in, metadata.foreign_key, :type => :array, :allow_nil => false)
            end
          end


          def create_embeds_many_accessors(metadata)
            validates_associated metadata.name

            redefine_method(metadata.name) do
              relation_proxy(metadata.name)
            end

            redefine_method(metadata.name+'=') do |records|
              relation_proxy(metadata.name).replace(records)
            end
          end

          def create_embedded_in_accessors(metadata)
            redefine_method(metadata.name) do
              relation_proxy(metadata.name)
            end

            redefine_method(metadata.name+'=') do |record|
              relation_proxy(metadata.name).replace(record)
            end
          end
        end



        def reload
          reset_relation_proxies
          super
        end

        def attributes=(attributes)
          attributes_for_relations = {}

          if relations && attributes.is_a?(Hash)
            attributes.stringify_keys!
            relation_names = relations.collect(&:name)

            attributes.delete_if do |attr_name, value|
              attributes_for_relations[attr_name] = value if relation_names.include? attr_name
            end
          end

          super(attributes)
          super(attributes_for_relations)
        end


        def relation_proxies
          (relations || []).map { |metadata| relation_proxy(metadata.name) }
        end

        def relation_proxies_for_embedded
          (relations || []).select(&:embedded?).map { |metadata| relation_proxy(metadata.name) }
        end


        private

        def create
          embedded_relations = relation_proxies_for_embedded.select(&:changed?)
          embedded_relations.each(&:parent_will_be_saved!)

          super

          embedded_relations.each(&:parent_has_been_saved!)
        end

        def update(attribute_names_to_update = attributes_with_embedded)
          embedded_relations = relation_proxies_for_embedded.select(&:changed?)
          embedded_relations.each(&:parent_will_be_saved!)

          super

          embedded_relations.each(&:parent_has_been_saved!)
        end

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

        def reset_relation_proxies
          @relation_proxy_cache.values.each(&:reset)
        end
      end
    end
  end
end
