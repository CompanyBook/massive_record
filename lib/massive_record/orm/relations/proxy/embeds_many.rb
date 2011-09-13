module MassiveRecord
  module ORM
    module Relations
      class Proxy
        class EmbedsMany < Proxy
          def initialize(options = {})
            super
            @raw = {}
          end


          def raw
            @raw.dup
          end


          def find(id)
            raise "TODO" # TODO
          end

          def limit(limit)
            raise "TODO" # TODO
          end



          def reset
            super
            @proxy_target = []
          end

          def replace(*records)
            records.flatten!

            if records.length == 1 and records.first.nil?
              reset
            else
              delete_all
              concat(records)
            end
          end


          #
          # Adding record(s) to the collection.
          #
          def <<(*records)
            records.flatten.each do |record|
              @raw[record.id] = record.attributes_to_row_values_hash
              proxy_target << record
            end
          end
          alias_method :push, :<<
          alias_method :concat, :<<

          #
          # Destroy record(s) from the collection
          # Each record will be asked to destroy itself as well
          #
          def destroy(*records)
            delete_or_destroy *records, :destroy
          end


          #
          # Deletes record(s) from the collection
          #
          def delete(*records)
            delete_or_destroy *records, :delete
          end

          #
          # Destroys all records
          #
          def destroy_all
            destroy(load_proxy_target)
            reset
            loaded!
          end

          #
          # Deletes all records from the relationship.
          # Does not destroy the records
          #
          def delete_all
            delete(load_proxy_target)
            reset
            loaded!
          end

          #
          # Checks if record is included in collection
          #
          def include?(record)
            load_proxy_target.include? record
          end

          def length
            load_proxy_target.length
          end
          alias_method :count, :length
          alias_method :size, :length

          def empty?
            length == 0
          end

          def first
            limit(1).first
          end




          private

          def find_proxy_target(options = {})
            raw.keys.each do |id|
              metadata.proxy_target_class.init_with :attributes => row[id]
            end
          end


          def delete_or_destroy(*records, method)
            records.flatten.each do |record|
              @raw.delete record.id
            end
          end

          def can_find_proxy_target?
            true
          end
        end
      end
    end
  end
end
