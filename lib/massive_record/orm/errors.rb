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

    # Raised if an attribute is unkown
    class UnkownAttributeError < MassiveRecordError
    end

    # Raised if id is missing when you try a save
    # TODO  It might be that we some time later will offer a kind of
    #       auto increment key functionality, and then this should only
    #       be raised if that is disabled.
    class IdMissing < MassiveRecordError
    end
  end
end
