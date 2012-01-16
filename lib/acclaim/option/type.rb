module Acclaim
  class Option

    # Associates a class with a handler block.
    module Type

      # The class methods.
      class << self

        # Yields class, proc pairs if a block was given. Returns an enumerator
        # otherwise.
        def each(&block)
          table.each &block
        end

        # Take advantage of #each implementation.
        include Enumerable

        # Returns all registered classes.
        def all
          table.keys
        end

        # Registers a handler for a class.
        def register(klass, &block)
          table[klass] = block
        end

        # Returns the handler for the given class.
        def handler_for(klass)
          table[klass]
        end

        # Same as #all.
        alias registered all

        # Same as #register.
        alias add_handler_for register

        # Same as #register.
        alias accept register

        # Same as #handler_for.
        alias [] handler_for

        private

        # The hash used to associate classes with their handlers.
        def table
          @table ||= {}
        end

      end

    end

  end
end

require 'acclaim/option/type/date'
require 'acclaim/option/type/date_time'
require 'acclaim/option/type/string'
require 'acclaim/option/type/symbol'
require 'acclaim/option/type/time'
require 'acclaim/option/type/uri'
