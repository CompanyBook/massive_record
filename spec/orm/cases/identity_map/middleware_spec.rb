require 'spec_helper'

module MassiveRecord::ORM::IdentityMap
  describe Middleware do
    before do
      @status_before = MassiveRecord::ORM::IdentityMap.enabled?
      MassiveRecord::ORM::IdentityMap.enabled = false
    end

    after do
      MassiveRecord::ORM::IdentityMap.enabled = @status_before
      MassiveRecord::ORM::IdentityMap.clear
    end


    it "delegates" do
      called = false
      mw = Middleware.new lambda { |env|
        called = true
      }
      mw.call({})

      called.should be_true
    end

    it "is enabled during delegation" do
      mw = Middleware.new lambda { |env|
        MassiveRecord::ORM::IdentityMap.should be_enabled
      }
      mw.call({})
    end


    class Enum < Struct.new(:iter)
      def each(&b)
        iter.call(&b)
      end
    end

    
    it "is enabled during body each" do
      mw = Middleware.new lambda { |env|
        [200, {}, Enum.new(lambda { |&b|
          MassiveRecord::ORM::IdentityMap.should be_enabled
          b.call "hello"
        })]
      }

      body = mw.call({}).last
      body.each { |x| x.should eq "hello" }
    end

    it "disables after close" do
      mw = Middleware.new lambda { |env| [200, {}, []] }
      body = mw.call({}).last
      MassiveRecord::ORM::IdentityMap.should be_enabled
      body.close
      MassiveRecord::ORM::IdentityMap.should_not be_enabled
    end

    it "is cleared after close" do
      mw = Middleware.new lambda { |env| [200, {}, []] }
      body = mw.call({}).last


      MassiveRecord::ORM::IdentityMap.send(:repository)['class'] = 'record'
      MassiveRecord::ORM::IdentityMap.send(:repository).should_not be_empty
      
      body.close
      MassiveRecord::ORM::IdentityMap.send(:repository).should be_empty
    end
  end
end

