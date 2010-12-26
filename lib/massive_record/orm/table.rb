require 'massive_record/orm/schema/table_interface'

module MassiveRecord
  module ORM
    class Table < Base
      include Schema::TableInterface
    end
  end
end
