module Acclaim
  class Option

    # Associates a class with a handler block.
    module Type

      instance_eval do

        # Yields class, proc pairs if a block was given. Returns an enumerator
        # otherwise.
        def each(&block)
          table.each &block
        end

        # Returns all registered classes.
        def all
          table.keys
        end

        alias registered all

        # Registers a handler for a class.
        def register(klass, &block)
          table[klass] = block
        end

        alias add_handler_for register
        alias accept register

        # Returns the handler for the given class.
        def handler_for(klass)
          table[klass]
        end

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
require 'acclaim/option/type/string'
