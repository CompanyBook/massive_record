module MassiveRecord
  module ORM
    module QueryInstrumentation
      module Table
        extend ActiveSupport::Concern

        module ClassMethods
          %w(find_one find_some find_all).each do |method_to_instrument|
            module_eval <<-RUBY, __FILE__, __LINE__

              def #{method_to_instrument}(*args)
                ActiveSupport::Notifications.instrument("load.massive_record", {
                  :name => [model_name, 'load'].join(' '),
                  :description => "#{method_to_instrument}",
                  :options => args
                }) do
                  super
                end
              end

            RUBY
          end
        end
      end

      module Operations
        def store_record_to_database(action, attribute_names_to_update = [])
          description = action + " id: #{record.id},"
          description += " attributes: #{attribute_names_to_update.join(', ')}" if attribute_names_to_update.any?

          ActiveSupport::Notifications.instrument("query.massive_record", {
            :name => [klass.model_name, 'save'].join(' '),
            :description => description
          }) do
            super
          end
        end
      end
    end
  end
end
