module MassiveRecord
  module ORM
    module Coders

      #
      # If you ever need support for multiple coders, this class can help you out.
      # Lets say you have YAML serialized data in your attributes, but what to migrate
      # over to JSON, you can:
      #   MassiveRecord::ORM::Base.coder = MassiveRecord::ORM::Coders::Chained.new({
      #     :load_with => [MassiveRecord::ORM::Coders::JSON.new, MassiveRecord::ORM::Coders::JSON.new],
      #     :dump_with => MassiveRecord::ORM::Coders::JSON.new
      #   })
      #
      # With this set we'll first try the JSON coder, and if it fails with an
      # encoding error we'll try the next one in the chain.
      #
      class Chained
        attr_reader :loaders, :dumpers

        def initialize(*args)
          coders = args.extract_options!

          @loaders = []
          @dumpers = []

          @loaders |= [coders[:load_with]].flatten if coders[:load_with]
          @dumpers |= [coders[:dump_with]].flatten if coders[:dump_with]
        end

        def dump(object)
          raise "We have no coders to dump with" if dumpers.empty?

          dumpers.each do |coder|
            return coder.dump(object)
          end
        end

        def load(data)
          raise "We have no coders to load with" if loaders.empty?

          loaders.each do |coder|
            return coder.load(data)
          end
        end
      end
    end
  end
end
