require 'active_support/secure_random'

#
# So, this module does a couple of things:
#   1.  Iterates over all tables and adds a prefix to
#       them so that the classes will be uniq for
#       the test run.
#   2.  Cleans tables' contents after each run
#   3.  Destroy tables after all
#
module MassiveRecord
  module Rspec
    module SimpleDatabaseCleaner
      extend ActiveSupport::Concern

      included do
        before(:all) { add_prefix_to_tables }

        after(:each) { delete_all_table_contents }
        after(:all) { delete_all_tables }
      end




      private




      def add_prefix_to_tables
        prefix = ActiveSupport::SecureRandom.hex(3)
        each_orm_class { |klass| klass.table_name_prefix = ["test", prefix, klass.table_name_prefix].reject(&:blank?).join("_") + "_" }
      end

      def delete_all_table_contents
        each_orm_class_where_table_exists { |klass| 
          klass.destroy_all
          # klass.connection.client.deleteAllRow(klass.table_name, "*")
        }
      end

      def delete_all_tables
        each_orm_class_where_table_exists { |klass| klass.table.destroy }
      end






      def each_orm_class
        MassiveRecord::ORM::Table.descendants.each { |klass| yield klass }
      end

      def each_orm_class_where_table_exists
        MassiveRecord::ORM::Table.descendants.select { |klass| klass.connection.tables.include? klass.table_name }.each { |klass| yield klass }
      end
    end
  end
end
