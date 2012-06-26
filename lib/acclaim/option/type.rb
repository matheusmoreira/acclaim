module Acclaim
  class Option

    # Associates a class with a handler block.
    #
    # @author Matheus Afonso Martins Moreira
    # @since 0.0.4
    module Type
    end

    # The class methods.
    class << Type

      # Yields class, proc pairs if a block was given. Returns an enumerator
      # otherwise.
      def each(&block)
        table.each &block
      end

      # Take advantage of each method.
      include Enumerable

      # Returns all registered classes.
      def all
        table.keys
      end

      alias registered all

      # Registers a handler for a class.
      def register(*klasses, &block)
        klasses.each { |klass| table[klass] = block }
      end

      alias add_handler_for register
      alias accept register

      # Returns the handler for the given class.
      def handler_for(klass)
        table.fetch klass do
          raise "#{klass} does not have an associated handler"
        end
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

%w(
  big_decimal
  complex
  date
  date_time
  float
  integer
  pathname
  rational
  string
  symbol
  time
  uri
).each do |type|
  require type.prepend 'acclaim/option/type/'
end
