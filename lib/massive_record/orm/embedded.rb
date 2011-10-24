require 'massive_record/orm/schema/embedded_interface'
require 'massive_record/orm/in_the_middle_of_saving_tracker'

module MassiveRecord
  module ORM
    class Embedded < Base
      include Schema::EmbeddedInterface
      include InTheMiddleOfSavingTracker

      DATABASE_ID_SEPARATOR = '|'


      # TODO  Embedded does not support these kind of methods
      class << self
        undef_method :first, :last, :all, :exists?, :destroy_all
      end


      def self.parse_database_id(database_id)
        if splitted = database_id.split(DATABASE_ID_SEPARATOR) and splitted.length == 2
          splitted
        else
          fail InvalidEmbeddedDatabaseId.new(
            <<-TXT
              Expected database id '#{database_id}' to be on a format like
              base_class_here#{DATABASE_ID_SEPARATOR}record_id_here
            TXT
          )
        end
      end

      def self.database_id(klass, id)
        [klass.base_class.to_s.underscore, id].join(DATABASE_ID_SEPARATOR)
      end

      #
      # Database id is base_class plus the record's id.
      # It is given, as we might want to embed records in an existing
      # column family, or share a family for multiple types. In which case,
      # we'll end up with a column family like this:
      #
      # | key           | attributes                                            |
      # --------------------------------------------------------------------------
      # | "address|123" | { :street => "Askerveien", :number => "12", etc... }  |
      # | "address|124" | { :street => "Askerveien", :number => "12", etc... }  |
      # | "name"        | "Thorbjorn Hermansen"                                 |
      # | "age"         | "30"                                                  |
      #
      # ..in this case we fetch embedded records to collection addresses by scoping
      # on keys which starts with base_class name. The records itself will only have
      # id equal to 123 and 124.
      #
      def database_id # :nodoc:
        if id
          self.class.database_id(self.class, id)
        end
      end

      #
      # Writer for database id. Used when loading records to easily set record's id.
      # Should not have the need to be used in other situations.
      #
      def database_id=(database_id) # :nodoc:
        self.id = self.class.parse_database_id(database_id)[1]
      end
    end
  end
end
