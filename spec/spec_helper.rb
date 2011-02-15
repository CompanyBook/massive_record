require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require :default, :development

SPEC_DIR = File.dirname(__FILE__) unless defined? SPEC_DIR
MR_CONFIG = YAML.load_file(File.join(SPEC_DIR, 'config.yml')) unless defined? MR_CONFIG

Rspec.configure do |c|
  #c.fail_fast = true 
end

Dir["#{SPEC_DIR}/orm/models/*.rb"].each { |f| require f }
Dir["#{SPEC_DIR}/support/**/*.rb"].each { |f| require f }
Dir["#{SPEC_DIR}/shared/**/*.rb"].each { |f| require f }
