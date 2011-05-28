require 'spec_helper'
require 'orm/models/person'
require 'orm/models/address'

#
# Some basic tests
#
shared_examples_for "Massive Record with callbacks" do
  it "should include ActiveModel::Callbacks" do
    @model.class.should respond_to :define_model_callbacks
  end

  it "should include ActiveModell::Validations::Callback" do
    @model.class.included_modules.should include(ActiveModel::Validations::Callbacks)
  end
end

{
  "MassiveRecord::Base::Table" => Person,
  "MassiveRecord::Base::Column" => Address
}.each do |orm_class, inherited_by_test_class|
  describe orm_class do
    before do
      @model = inherited_by_test_class.new
    end

    it_should_behave_like "Massive Record with callbacks"
  end
end


#
# Some real life object tests
#
class CallbackDeveloper < MassiveRecord::ORM::Table
  class << self
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

  MassiveRecord::ORM::Callbacks::CALLBACKS.each do |callback_method|
    next if callback_method.to_s =~ /^around_/
    define_callback_method(callback_method)
    send(callback_method, callback_string(callback_method))
    send(callback_method, callback_proc(callback_method))
    send(callback_method, callback_object(callback_method))
    send(callback_method) { |model| model.history << [callback_method, :block] }
  end

  def history
    @history ||= []
  end
end


describe "callbacks for" do
  include MockMassiveRecordConnection

  it "initialize should run in correct order" do
    thorbjorn = CallbackDeveloper.new
    thorbjorn.history.should == [
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc],
      [:after_initialize, :object],
      [:after_initialize, :block]
    ]
  end

  it "find should run in correct order" do
    thorbjorn = CallbackDeveloper.find(1)
    thorbjorn.history.should == [
      [:after_find, :method],
      [:after_find, :string],
      [:after_find, :proc],
      [:after_find, :object],
      [:after_find, :block],
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc],
      [:after_initialize, :object],
      [:after_initialize, :block]
    ]
  end

  it "touch should run in correct order" do
    thorbjorn = CallbackDeveloper.find(1)
    thorbjorn.touch
    thorbjorn.history.should == [
      [:after_find, :method],
      [:after_find, :string],
      [:after_find, :proc],
      [:after_find, :object],
      [:after_find, :block],
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc],
      [:after_initialize, :object],
      [:after_initialize, :block],
      [:after_touch, :method],
      [:after_touch, :string],
      [:after_touch, :proc],
      [:after_touch, :object],
      [:after_touch, :block]
    ]
  end
  
  it "valid for new record should run in correct order" do
    thorbjorn = CallbackDeveloper.new
    thorbjorn.valid?
    thorbjorn.history.should == [
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc],
      [:after_initialize, :object],
      [:after_initialize, :block],
      [:before_validation, :method],
      [:before_validation, :string],
      [:before_validation, :proc],
      [:before_validation, :object],
      [:before_validation, :block],
      [:after_validation, :method],
      [:after_validation, :string],
      [:after_validation, :proc],
      [:after_validation, :object],
      [:after_validation, :block]
    ]
  end

  it "valid for exiting record should run in correct order" do
    thorbjorn = CallbackDeveloper.find(1)
    thorbjorn.valid?
    thorbjorn.history.should == [
      [:after_find, :method],
      [:after_find, :string],
      [:after_find, :proc],
      [:after_find, :object],
      [:after_find, :block],
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc],
      [:after_initialize, :object],
      [:after_initialize, :block],
      [:before_validation, :method],
      [:before_validation, :string],
      [:before_validation, :proc],
      [:before_validation, :object],
      [:before_validation, :block],
      [:after_validation, :method],
      [:after_validation, :string],
      [:after_validation, :proc],
      [:after_validation, :object],
      [:after_validation, :block]
    ]
  end

  it "create should run in correct order" do
    thorbjorn = CallbackDeveloper.create "dummy"
    thorbjorn.history.should == [
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc  ],
      [:after_initialize, :object],
      [:after_initialize, :block ],
      [:before_validation, :method],
      [:before_validation, :string],
      [:before_validation, :proc  ],
      [:before_validation, :object],
      [:before_validation, :block ],
      [:after_validation, :method],
      [:after_validation, :string],
      [:after_validation, :proc  ],
      [:after_validation, :object],
      [:after_validation, :block ],
      [:before_save, :method],
      [:before_save, :string],
      [:before_save, :proc  ],
      [:before_save, :object],
      [:before_save, :block ],
      [:before_create, :method],
      [:before_create, :string],
      [:before_create, :proc  ],
      [:before_create, :object],
      [:before_create, :block ],
      [:after_create, :method],
      [:after_create, :string],
      [:after_create, :proc  ],
      [:after_create, :object],
      [:after_create, :block ],
      [:after_save, :method],
      [:after_save, :string],
      [:after_save, :proc  ],
      [:after_save, :object],
      [:after_save, :block ]
    ]
  end

  it "update should run in correct order" do
    thorbjorn = CallbackDeveloper.find(1)
    thorbjorn.save
    thorbjorn.history.should == [
      [:after_find, :method],
      [:after_find, :string],
      [:after_find, :proc],
      [:after_find, :object],
      [:after_find, :block],
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc  ],
      [:after_initialize, :object],
      [:after_initialize, :block ],
      [:before_validation, :method],
      [:before_validation, :string],
      [:before_validation, :proc  ],
      [:before_validation, :object],
      [:before_validation, :block ],
      [:after_validation, :method],
      [:after_validation, :string],
      [:after_validation, :proc  ],
      [:after_validation, :object],
      [:after_validation, :block ],
      [:before_save, :method],
      [:before_save, :string],
      [:before_save, :proc  ],
      [:before_save, :object],
      [:before_save, :block ],
      [:before_update, :method],
      [:before_update, :string],
      [:before_update, :proc  ],
      [:before_update, :object],
      [:before_update, :block ],
      [:after_update, :method],
      [:after_update, :string],
      [:after_update, :proc  ],
      [:after_update, :object],
      [:after_update, :block ],
      [:after_save, :method],
      [:after_save, :string],
      [:after_save, :proc  ],
      [:after_save, :object],
      [:after_save, :block ]
    ]
  end

  it "destroy should run in correct order" do
    thorbjorn = CallbackDeveloper.find(1) 
    thorbjorn.destroy
    thorbjorn.history.should == [
      [:after_find, :method],
      [:after_find, :string],
      [:after_find, :proc],
      [:after_find, :object],
      [:after_find, :block],
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc  ],
      [:after_initialize, :object],
      [:after_initialize, :block ],
      [:before_destroy, :method],
      [:before_destroy, :string],
      [:before_destroy, :proc  ],
      [:before_destroy, :object],
      [:before_destroy, :block ],
      [:after_destroy, :method],
      [:after_destroy, :string],
      [:after_destroy, :proc  ],
      [:after_destroy, :object],
      [:after_destroy, :block ]
    ]
  end

  it "should not run callbacks for destroy on delete" do
    thorbjorn = CallbackDeveloper.find(1) 
    thorbjorn.delete
    thorbjorn.should be_destroyed
    thorbjorn.history.should == [
      [:after_find, :method],
      [:after_find, :string],
      [:after_find, :proc],
      [:after_find, :object],
      [:after_find, :block],
      [:after_initialize, :method],
      [:after_initialize, :string],
      [:after_initialize, :proc  ],
      [:after_initialize, :object],
      [:after_initialize, :block ]
    ]
  end
end
