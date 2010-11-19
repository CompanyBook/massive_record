SPEC_DIR = File.dirname(__FILE__) unless defined? SPEC_DIR
lib_path = File.expand_path("#{SPEC_DIR}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'massive_record'
require 'yaml'

MR_CONFIG = YAML.load_file(File.join(SPEC_DIR, 'config.yml')) unless defined? MR_CONFIG