require 'massive_record/orm/schema/embedded_interface'

module MassiveRecord
  module ORM
    class Column < Base
      include Schema::EmbeddedInterface

      # TODO  Embedded does not support these kind of methods
      class << self
        undef_method :first, :last, :all, :exists?, :destroy_all
      end

      undef_method :create, :reload, :save, :save!, :update_attribute, :update_attributes,
        :update_attributes!, :touch, :destroy, :increment!, :atomic_increment!,
        :decrement!, :delete



      def self.inherited(by_class)
        ActiveSupport::Deprecation.warn(
          <<-TXT
            #{by_class} inherits from MassiveRecord::ORM::Column which has been renamed to
            MassiveRecord::ORM::Embedded. Please inherit from the Embedded class instead as
            Column will be removed in the an upcomming of MassiveRecord.
          TXT
        )
      end
    end
  end
end
