module MassiveRecord
  module ORM

    # Generic error / exception class
    class MassiveRecordError < StandardError
    end


    # Railsed by save! and create!
    class RecordNotSaved < MassiveRecordError
    end

  end
end
