require 'spec_helper'

class TestProxy < MassiveRecord::ORM::Relations::Proxy; end

describe TestProxy do
  subject { TestProxy.new }

  it_should_behave_like MassiveRecord::ORM::Relations::Proxy
end
