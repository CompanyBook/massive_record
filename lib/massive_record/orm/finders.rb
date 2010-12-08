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

          type = args.shift if args.first.is_a? Symbol

          attributes =  if type
                          table.send(type, *args)
                        else
                          table.find(*args)
                        end

          raise RecordNotFound if attributes.blank?
          
          # TODO  We need to map column_family:column keys to what
          #       is expected to be put in attributes; meaning that
          #       if our schema is as follows:
          #         
          #         column_family :info do
          #           field :name
          #           field :email
          #         end
          #
          #       it means that instantiate should be instantiated with
          #       hash which has keys like name, email and so on.
          #

          # p attributes.values  # <<--- Hash which we need to transpose

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
