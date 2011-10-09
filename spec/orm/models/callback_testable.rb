module CallbackTestable
  extend ActiveSupport::Concern

  included do
    MassiveRecord::ORM::Callbacks::CALLBACKS.each do |callback_method|
      next if callback_method.to_s =~ /^around_/
      define_callback_method(callback_method)
      send(callback_method, callback_string(callback_method))
      send(callback_method, callback_proc(callback_method))
      send(callback_method, callback_object(callback_method))
      send(callback_method) { |model| model.history << [callback_method, :block] }
    end
  end

  module ClassMethods
    def callback_string(callback_method)
      "history << [#{callback_method.to_sym.inspect}, :string]"
    end

    def callback_proc(callback_method)
      Proc.new { |model| model.history << [callback_method, :proc] }
    end

    def define_callback_method(callback_method)
      define_method(callback_method) do
        self.history << [callback_method, :method]
      end
      send(callback_method, :"#{callback_method}")
    end

    def callback_object(callback_method)
      klass = Class.new
      klass.send(:define_method, callback_method) do |model|
        model.history << [callback_method, :object]
      end
      klass.new
    end
  end


  def history
    @history ||= []
  end
end
