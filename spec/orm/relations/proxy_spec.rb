require 'spec_helper'

class TestProxy < MassiveRecord::ORM::Proxy; end

describe TestProxy do
  subject { TestProxy.new }

  it_should_behave_like MassiveRecord::ORM::Proxy
end
