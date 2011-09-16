module MassiveRecord
  module ORM
    class Column < Base
      def self.inherited(by_class)
        raise(<<-TXT
            #{by_class} inherits from MassiveRecord::ORM::Column which has been renamed to
            MassiveRecord::ORM::Embedded. Please inherit from the Embedded class instead as
            Column will be removed in the an upcomming of MassiveRecord.
          TXT
        )
      end
    end
  end
end
