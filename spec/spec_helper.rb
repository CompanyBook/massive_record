require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require :default, :development

SPEC_DIR = File.dirname(__FILE__) unless defined? SPEC_DIR
MR_CONFIG = YAML.load_file(File.join(SPEC_DIR, 'config.yml')) unless defined? MR_CONFIG

Rspec.configure do |c|

end
