module MassiveRecord
  module ORM
    module Finders
      extend ActiveSupport::Concern

      module ClassMethods
        #
        # Interface for retrieving objects based on key.
        # Has some convenience behaviour like find :first, :last, :all.
        #
        def find(*args)
          raise ArgumentError.new("At least one argument required!") if args.empty?
          raise RecordNotFound.new("Can't find a #{model_name.human} without an ID.") if args.first.nil?

          type = args.shift if args.first.is_a? Symbol

          row = if type
                  table.send(type, *args)
                else
                  table.find(*args)
                end

          raise RecordNotFound if row.blank?
          
          # Map column_family:column keys to what
          # is expected to be put in attributes; meaning that
          # if our schema is as follows:
          #   
          #   column_family :info do
          #     field :name
          #     field :email
          #   end
          # 
          # it means that instantiate should be instantiated with
          # hash which has keys like name, email and so on.
          #
          attributes = {}
          attributes_schema.each do |key, field|
            column = row.columns[field.unique_name]
            attributes[field.name] = column.nil? ? nil : column.value
          end
          instantiate(attributes.merge({ :id => row.id }))
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
