module MassiveRecord
  module ORM
    module AttributeMethods
      module Dirty
        extend ActiveSupport::Concern
        include ActiveModel::Dirty


        def save(*)
          if status = super
            changes_before_save = changes
            clear_dirty_states!
            @previously_changed = changes_before_save
          end
          status
        end

        def save!(*)
          super.tap do
            changes_before_save = changes
            clear_dirty_states!
            @previously_changed = changes_before_save
          end
        end

        def reload(*)
          super.tap do
            clear_dirty_states!
          end
        end

        def write_attribute(attr_name, value)
          attr_name = attr_name.to_s

          if will_change_attribute?(attr_name, value)
            if will_change_back_to_original_value?(attr_name, value)
              changed_attributes.delete(attr_name)
            else
              super(attr_name, original_attribute_value(attr_name))
              send("#{attr_name}_will_change!")
            end
          end

          super
        end


        def changed?
          super || relation_proxies_for_embedded.any?(&:changed?)
        end

        def changed
          super + relation_proxies_for_embedded.select(&:changed?).collect { |proxy| proxy.metadata.name }
        end

        def changes
          changes_in_embedded_proxies = {}

          relation_proxies_for_embedded.select(&:changed?).each do |proxy|
            changes_in_embedded_proxies[proxy.metadata.name] = proxy.changes 
          end

          super.update(changes_in_embedded_proxies)
        end

        private

        def update(*)
          changes.empty? ? true : super(changes.keys)
        end

        def original_attribute_value(attr_name)
          @original_attribute_values ||= {}

          unless @original_attribute_values.has_key? attr_name
            @original_attribute_values[attr_name] = send(attr_name)
          end

          @original_attribute_values[attr_name]
        end

        def will_change_attribute?(attr_name, value)
          read_attribute(attr_name) != decode_attribute(attr_name, value)
        end

        def will_change_back_to_original_value?(attr_name, value)
          original_attribute_value(attr_name) == decode_attribute(attr_name, value)
        end

        def clear_dirty_states!
          changed_attributes.clear
          @original_attribute_values.clear if @original_attribute_values
          @previously_changed.clear if @previously_changed
        end
      end
    end
  end
end
