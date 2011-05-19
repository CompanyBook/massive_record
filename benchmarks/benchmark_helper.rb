require 'rubygems'
require 'bundler'
require 'benchmark'

Bundler.require :default, :development

BENCHMARK_DIR ||= File.dirname(File.absolute_path(__FILE__)) unless defined? BENCHMARK_DIR
MR_CONFIG ||= YAML.load_file(File.join(BENCHMARK_DIR, 'config.yml')) unless defined? MR_CONFIG


CONNECTION ||= MassiveRecord::Wrapper::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port']).tap do |connection|
  connection.open
end

TABLE ||= MassiveRecord::Wrapper::Table.new(CONNECTION, MR_CONFIG['table'])

TABLE.column_families.create(:base)
TABLE.save

Dir["#{BENCHMARK_DIR}/adapter/**/*.rb"].each { |f| require f }

TABLE.destroy
