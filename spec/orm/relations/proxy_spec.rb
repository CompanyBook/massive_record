require 'spec_helper'

class TestProxy < MassiveRecord::ORM::Relations::Proxy; end

describe TestProxy do
  it_should_behave_like "relation proxy"
end
