module MassiveRecord; end

# Adapter
require 'massive_record/adapters/initialize'

# Wrapper
require 'massive_record/wrapper/base'

# ORM
require 'massive_record/orm/base'
require 'massive_record/orm/raw_data'

# Others
if defined?(::Rails) && ::Rails::VERSION::MAJOR == 3
  require 'massive_record/rails/railtie'
end

require 'active_support/core_ext'

ActiveSupport::JSON.backend = :yajl