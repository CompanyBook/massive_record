module MassiveRecord
  module ORM
    
    #
    # Parent class for all proxies sitting between records
    #
    class Proxy
      instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|inspect|to_s)$|^__|^respond_to|^should/ }

      attr_accessor :owner, :target, :metadata, :loaded


      def loaded?
        !!@loaded
      end
    end
  end
end
