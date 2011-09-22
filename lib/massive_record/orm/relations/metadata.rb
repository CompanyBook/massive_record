require 'active_support/core_ext/array/extract_options'

module MassiveRecord
  module ORM
    module Relations
      # Raised when an invalid start option is given to a find_in_batches
      class InvalidStartsWithOption < MassiveRecordError
      end

      #
      # The master of metadata related to a relation. For instance;
      # references_one :employee, :foreign_key => "person_id", :class_name => "Person"
      #
      class Metadata
        attr_writer :foreign_key, :store_in, :class_name, :name, :relation_type, :polymorphic, :inverse_of
        attr_accessor :find_with, :owner_class
        attr_reader :records_starts_from
        
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
          self.records_starts_from = options[:records_starts_from] if options[:records_starts_from]
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

        def inverse_of
          (@inverse_of || calculate_inverse_of).to_s
        end

        def proxy_target_class
          class_name.constantize
        end

        def store_in
          return @store_in.to_s if @store_in
          @store_in = name if embedded?
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
          !embedded? && !!store_in && !records_starts_from
        end


        def polymorphic
          !!@polymorphic
        end
        alias polymorphic? polymorphic

        def embedded
          relation_type == "embeds_many"
        end
        alias embedded? embedded


        def new_relation_proxy(proxy_owner)
          proxy_class_name.constantize.new(:proxy_owner => proxy_owner, :metadata => self)
        end

        
        def ==(other)
          other.instance_of?(self.class) && other.hash == hash
        end
        alias_method :eql?, :==

        def hash
          name.hash
        end



        def represents_a_collection?
          %w(references_many embeds_many).include? relation_type
        end

        #
        # Sets a method which we should ask for how to find where
        # related records starts with. Method injects a find_with
        # Proc which finds are made through.
        #
        # That proc takes different options as it sends on to the
        # receiving finder method on target class. It also takes a
        # block which is sent on to the finder method.
        #
        def records_starts_from=(method)
          @records_starts_from = method

          if @records_starts_from
            self.find_with = Proc.new do |proxy_owner, options = {}, &block|
              options = MassiveRecord::Adapters::Thrift::Table.warn_and_change_deprecated_finder_options(options)

              finder_method = options.delete(:finder_method) || :all

              if ids_starts_with = proxy_owner.send(records_starts_from)
                if options[:starts_with]
                  if options[:starts_with].starts_with?(ids_starts_with)
                    ids_starts_with = options[:starts_with]
                  else
                    raise InvalidStartsWithOption.new("The starts with option: #{options[:starts_with]} must begin with: #{ids_starts_with}.")
                  end
                end
                proxy_target_class.send(finder_method, options.merge({:starts_with => ids_starts_with}), &block)
              end
            end
          else
            self.find_with = nil
          end
        end


        private


        def calculate_class_name
          name.to_s.classify
        end

        def calculate_inverse_of
          raise "Can't return inverse of without it being explicitly set or without an owner_class" unless owner_class
          owner_class.to_s.demodulize.downcase.pluralize
        end

        def calculate_foreign_key
          if represents_a_collection?
            name.downcase.singularize + "_ids"
          else
            name.downcase + "_id"
          end
        end

        def proxy_class_name
          "MassiveRecord::ORM::Relations::Proxy::"+relation_type.classify
        end
      end
    end
  end
end
