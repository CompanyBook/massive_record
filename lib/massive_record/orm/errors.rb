module MassiveRecord
  module ORM

    # Generic error / exception class
    class MassiveRecordError < StandardError
    end


    # Railsed by save! and create! if the record passes
    # validation, but for some reason was not saved.
    class RecordNotSaved < MassiveRecordError
    end
    
    # Raised if a conncetion was being accessed, but no
    # configuration was set to tell us how to connect.
    class ConnectionConfigurationMissing < MassiveRecordError
    end

    # Raised on find(id) when id does not exist.
    class RecordNotFound < MassiveRecordError
    end

    # Raised when we try to create a new record with an id which exists.
    class RecordNotUnique < MassiveRecordError
    end

    # Raised if an attribute is unkown
    class UnknownAttributeError < MassiveRecordError
    end

    # Raised if id is missing when you try a save
    # TODO  It might be that we some time later will offer a kind of
    #       auto increment key functionality, and then this should only
    #       be raised if that is disabled.
    class IdMissing < MassiveRecordError
    end

    class ColumnFamiliesMissingError < MassiveRecordError
      attr_reader :missing_column_families
      def initialize(klass, missing_column_families)
        @missing_column_families = missing_column_families
        super("hbase are missing some column families for class '#{klass.to_s}', table '#{klass.table_name}': #{@missing_column_families.join(' ')}. Please migrate the database.")
      end
    end

    # Raised when trying to manipulate non-numeric fields by operations
    # requiring a number to work on.
    class NotNumericalFieldError < MassiveRecordError
    end

    # Raised if you try to assign a variable which can't be set manually,
    # for instance time stamps
    class CantBeManuallyAssigned < MassiveRecordError
    end

    # Raised if you try to save a record which is read only
    class ReadOnlyRecord < MassiveRecordError
    end


    # Raised when a relation s already defined
    class RelationAlreadyDefined < MassiveRecordError
    end

    # Raised if proxy_target in a relation proxy does not match what the proxy expects
    class RelationTypeMismatch < MassiveRecordError
    end

    # Raised when an attribute is decoded from the database, but the type returned does not match what is expected
    class SerializationTypeMismatch < MassiveRecordError
    end
  end
end
