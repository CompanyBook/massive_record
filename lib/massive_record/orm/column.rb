require 'massive_record/orm/schema/column_interface'

module MassiveRecord
  module ORM
    class Column < Base
      include Schema::ColumnInterface

      # TODO  Column does not support these kind of methods
      class << self
        undef_method :first, :last, :all, :exists?, :destroy_all
      end

      undef_method :create, :reload, :save, :save!, :update_attribute, :update_attributes,
        :update_attributes!, :touch, :destroy, :increment!, :atomic_increment!,
        :decrement!, :delete
    end
  end
end
