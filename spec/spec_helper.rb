$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'support'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'shared'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'orm', 'models'))

require 'rubygems'
require 'bundler'
require 'yaml'
require 'massive_record'

Bundler.require :default, :development

SPEC_DIR = File.dirname(__FILE__) unless defined? SPEC_DIR
MR_CONFIG = YAML.load_file(File.join(SPEC_DIR, 'config.yml')) unless defined? MR_CONFIG

RSpec.configure do |c|
  #c.fail_fast = true 
end


Dir["#{SPEC_DIR}/shared/**/*.rb"].each { |f| require f }
Dir["#{SPEC_DIR}/support/**/*.rb"].each { |f| require f }
Dir["#{SPEC_DIR}/orm/models/*.rb"].each { |f| require f }

require 'massive_record/orm/identity_map'
MassiveRecord::ORM::IdentityMap.enabled = false
if MassiveRecord::ORM::IdentityMap.enabled?
  RSpec.configure do |c|
    puts "IdentityMap is enabled!"
    c.before { MassiveRecord::ORM::IdentityMap.clear }
  end
end
