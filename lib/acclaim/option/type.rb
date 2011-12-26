module Acclaim
  class Option

    # Associates a class with a handler block.
    module Type

      # Yields class, proc pairs if a block was given. Returns an enumerator
      # otherwise.
      def self.each(&block)
        table.each &block
      end

      # Returns all registered classes.
      def self.all
        table.keys
      end

      # Registers a handler for a class.
      def self.register(klass, &block)
        table[klass] = block
      end

      # Returns the handler for the given class.
      def self.handler_for(klass)
        table[klass]
      end

      class << self
        alias registered all
        alias add_handler_for register
        alias accept register
        alias [] handler_for
      end

      # The hash used to associate classes with their handlers.
      def self.table
        @table ||= {}
      end

      private_class_method :table

    end

  end
end

require 'acclaim/option/type/date'
require 'acclaim/option/type/date_time'
require 'acclaim/option/type/string'
require 'acclaim/option/type/symbol'
require 'acclaim/option/type/time'
require 'acclaim/option/type/uri'
