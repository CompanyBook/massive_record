require 'massive_record/orm/schema/column_interface'

module MassiveRecord
  module ORM
    class Column < Base
      include Schema::ColumnInterface
    end
  end
end
