require 'active_support/secure_random'

#
# This module does a couple of things:
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
        before(:all) { add_suffix_to_tables }
        after(:each) { delete_all_tables }
      end

      private

      def add_suffix_to_tables
        each_orm_class { |klass| klass.reset_table_name_configuration!; klass.table_name_suffix = '_test' }
      end

      def delete_all_tables
        tables = MassiveRecord::ORM::Base.connection.tables
        each_orm_class { |klass| klass.destroy_all and tables.delete(klass.table.name) if tables.include? klass.table.name }
      end

      def each_orm_class
        MassiveRecord::ORM::Table.descendants.each { |klass| yield klass }
      end
    end
  end
end
