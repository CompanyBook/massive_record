require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require :default, :development

SPEC_DIR = File.dirname(__FILE__) unless defined? SPEC_DIR
MR_CONFIG = YAML.load_file(File.join(SPEC_DIR, 'config.yml')) unless defined? MR_CONFIG

RSpec.configure do |c|
  #c.fail_fast = true 
end

Dir["#{SPEC_DIR}/orm/models/*.rb"].each { |f| require f }
Dir["#{SPEC_DIR}/support/**/*.rb"].each { |f| require f }
Dir["#{SPEC_DIR}/shared/**/*.rb"].each { |f| require f }


MassiveRecord::ORM::IdentityMap.enabled = false
if MassiveRecord::ORM::IdentityMap.enabled?
  RSpec.configure do |c|
    puts "IdentityMap is enabled!"
    c.before { MassiveRecord::ORM::IdentityMap.clear }
  end
end
