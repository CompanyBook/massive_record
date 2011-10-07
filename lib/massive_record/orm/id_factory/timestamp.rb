module MassiveRecord
  module ORM
    module IdFactory

      #
      # Factory class for ids based on time stamps. It does not guarantee uniqueness
      # on ids, but if you use microseconds as precision you should be at least a bit
      # better of then using seconds..
      #
      # This factory is mostly intended to generate ids for embedded records, and was
      # written as a result of Companybook not wanting to id the AtomicIncrementation
      # id factory for every embedded record. It might be, in the future, an idea to
      # take a second look at this one to make it guarantee it's uniqueness of ids.
      #
      class Timestamp
        include IdFactory

        cattr_accessor :precision, :reverse_time, :instance_writer => false
        self.precision = :microseconds
        self.reverse_time = true


        private

        def next_id(options = {})
          options.assert_valid_keys(:table)
          table_name = options.delete :table

          time_to_id Time.now
        end


        def time_to_id(time)
          floated_time = time.getutc.to_f

          case precision
          when :s, :seconds
            if reverse_time
              (10**10 - 1 - (floated_time).to_i).to_s
            else
              (floated_time).to_i.to_s
            end
          when :ms, :milliseconds
            if reverse_time
              (10**13 - 1 - (floated_time * 1000).to_i).to_s
            else
              (floated_time * 1000).to_i.to_s
            end
          when :us, :microseconds
            if reverse_time
              (10**16 - 1 - (floated_time * 1000000).to_i).to_s
            else
              (floated_time * 1000000).to_i.to_s
            end
          end
        end
      end
    end
  end
end
