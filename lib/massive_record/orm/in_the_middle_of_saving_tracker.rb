module MassiveRecord
  module ORM

    #
    # Tracks if we are in the middle of being saved or not, and if
    # we are asked valid? in the middle of a save, we'll return the
    # last answer we gave to that question, instead of running
    # validations again.
    #
    #
    # Main reason for doing so is when used in conjunction with
    # Embedded records, in the following situations:
    #
    # 1. Calling save on an embedded record when the owner
    #    is not persisted will call save on the same
    #    record again when owner is saved and informs
    #    embeds many proxy that it is being about to be
    #    saved. Resulting in all callbacks fire again
    #    on the record which issued the save in the first
    #    place.
    #
    #    We can query each embedded record inside of
    #    embeds_many#parent_will_be_saved! if we are to call save
    #    on it (to make each embedded record update it's persisted state),
    #    or if we should not do it, if the embedded record was the one
    #    triggered the save in the first place.
    #
    # 2. Calling save on an embedded record when the owner
    #    is not persisted will first validate the embedded
    #    record, then the owner will validate all associated
    #    records, including the one record which issued
    #    the save and therefor is validated.
    # 
    #     We can controll if we are to run validations on a record
    #     or not, based if we are in the middle of a save on current
    #     record, thus callbacks (like before_validations etc) will
    #     not run twice.
    #
    module InTheMiddleOfSavingTracker
      attr_reader :in_the_middle_of_saving
      alias in_the_middle_of_saving? in_the_middle_of_saving

      def save(options = {})
        with_in_the_middle_of_saving_tracker { super }
      end

      def save!(options = {})
        with_in_the_middle_of_saving_tracker { super }
      end

      def valid?(*)
        if in_the_middle_of_saving?
          if @last_valid_value_inside_of_current_save.nil?
            @last_valid_value_inside_of_current_save = super
          else
            @last_valid_value_inside_of_current_save
          end
        else
          super
        end
      end

      
      private
      
      def with_in_the_middle_of_saving_tracker
        @in_the_middle_of_saving = true
        yield
      ensure
        @in_the_middle_of_saving = false
        @last_valid_value_inside_of_current_save = nil
      end
    end
  end
end
