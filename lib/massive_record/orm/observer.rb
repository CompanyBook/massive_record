module MassiveRecord
  module ORM

    #
    # MassiveRecord Observer. Greatly influenced by ActiveRecord's
    # way of doing callbacks, thus should feel familiar to most people.
    #
    # NOTE  that if you are using rails you should add observers to into
    #       your application.rb configuration file like this:
    #
    #       config.massive_record.observers = :person_observer, :audit_observer
    #
    #       This will ensure that observers are loaded correctly. If you are not
    #       using rails you can do: MassiveRecord::ORM::Base.instantiate_observers
    #       after your application has been initialized.
    #
    # Example of usage:
    #
    # class Person < MassiveRecord::ORM::Table
    #   column_family :info do
    #     field :name
    #   end
    # end
    #
    # class PersonObserver < MassiveRecord::ORM::Observer
    #   def after_save(saved_person_record)
    #     # do something here after people are being saved
    #   end
    # end
    #
    # class AuditObserver < MassiveRecord::ORM::Observer
    #   observe :person, :and, :other, :classes
    #
    #   def after_save(saved_person_record)
    #     # do something here after people are being saved
    #   end
    # end
    #
    class Observer < ActiveModel::Observer
      protected

      def observed_classes
        klasses = super
        klasses + klasses.map { |klass| klass.descendants }.flatten
      end

      def add_observer!(klass)
        super
        define_callbacks klass
      end

      def define_callbacks(klass)
        observer = self
        observer_name = observer.class.name.underscore.gsub('/', '__')

        MassiveRecord::ORM::Callbacks::CALLBACKS.each do |callback|
          next unless respond_to?(callback)
          callback_meth = :"_notify_#{observer_name}_for_#{callback}"
          unless klass.respond_to?(callback_meth)
            klass.send(:define_method, callback_meth) do |&block|
              observer.send(callback, self, &block)
            end
            klass.send(callback, callback_meth)
          end
        end
      end
    end
  end
end
