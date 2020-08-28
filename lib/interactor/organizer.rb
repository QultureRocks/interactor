module Interactor
  # Public: Interactor::Organizer methods. Because Interactor::Organizer is a
  # module, custom Interactor::Organizer classes should include
  # Interactor::Organizer rather than inherit from it.
  #
  # You can also pass the interactos as a hash that allows you to define a condition to decide if the 
  # interactor will be executed or not. The hash must have the following format: 
  #   { interactor: InteractorOne, condition: -> { false } }
  # 
  # Examples
  #
  #   class MyOrganizer
  #     include Interactor::Organizer
  #
  #     organizer InteractorOne, InteractorTwo
  #   end
  #
  #   class MyOrganizer
  #     include Interactor::Organizer
  #
  #     organizer InteractorOne, { interactor: InteractorTwo, condition: -> { true } }
  #   end
  #
  #   class MyOrganizer
  #     include Interactor::Organizer
  #
  #     organizer { interactor: InteractorOne, condition: -> { false } }, { interactor: InteractorTwo, condition: -> { true } }
  #   end
  #
  #
  # 
  module Organizer
    # Internal: Install Interactor::Organizer's behavior in the given class.
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    # Internal: Interactor::Organizer class methods.
    module ClassMethods
      # Public: Declare Interactors to be invoked as part of the
      # Interactor::Organizer's invocation and map it to hash format. 
      # These interactors are invoked in the order in which they are declared.
      #
      # interactors - Zero or more (or an Array of) Interactor classes.
      #
      # Examples
      #
      #   class MyFirstOrganizer
      #     include Interactor::Organizer
      #
      #     organize InteractorOne, InteractorTwo
      #   end
      #
      #   class MySecondOrganizer
      #     include Interactor::Organizer
      #
      #     organize [InteractorThree, InteractorFour]
      #   end
      #
      #   class MyThirdOrganizer
      #     include Interactor::Organizer
      #
      #     organizer InteractorOne, { interactor: InteractorTwo, condition: -> { true } }
      #   end
      #
      # Returns nothing.
      def organize(*interactors)
        @organized = interactors.flatten.map do |interactor| 
          interactor.is_a?(Hash) ? interactor : { interactor: interactor, condition: -> { true } }
        end
      end

      # Internal: An Array of declared Interactors to be invoked.
      #
      # Examples
      #
      #   class MyOrganizer
      #     include Interactor::Organizer
      #
      #     organize InteractorOne, InteractorTwo
      #   end
      #
      #   MyOrganizer.organized
      #   # => [{ interactor: InteractorOne, condition: -> { true } }, {interactor: InteractorTwo, condition: -> { true } }]
      #
      # Returns an Array of Interactor classes or an empty Array.
      def organized
        @organized ||= []
      end
    end

    # Internal: Interactor::Organizer instance methods.
    module InstanceMethods
      # Internal: Invoke the organized Interactors if the condition passed is true. 
      # If no condition flag was passed, the default value is true. An Interactor::Organizer
      # is expected not to define its own "#call" method in favor of this default
      # implementation.
      #
      # Returns nothing.
      def call
        self.class.organized.each do |interactor_hash|
          interactor_hash[:interactor].call!(context) if instance_exec(&interactor_hash[:condition])
        end
      end
    end
  end
end
