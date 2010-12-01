module MassiveRecord
  module ORM
    module Persistence
      def new_record?
        @new_record
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      def destroyed?
        @destroyed
      end


      

      def save(*)
        create_or_update
      end

      def destroy
        @destroyed = true
        true
      end

      def delete
        @destroyed = true
        true
      end


      private


      def create_or_update
        !!(new_record? ? create : update)
      end

      def create
        @new_record = false
        true
      end

      def update
        true
      end
    end
  end
end
