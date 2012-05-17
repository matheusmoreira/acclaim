module Acclaim
  class Option

    # Associates a class with a handler block.
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

      # Registers a handler for a class.
      def register(klass, &block)
        table[klass] = block
      end

      # Returns the handler for the given class.
      def handler_for(klass)
        table.fetch klass do
          raise "#{klass} does not have an associated handler"
        end
      end

      # Same as <tt>all</tt>.
      alias registered all

      # Same as <tt>register</tt>.
      alias add_handler_for register

      # Same as <tt>register</tt>.
      alias accept register

      # Same as <tt>handler_for</tt>.
      alias [] handler_for

      private

      # The hash used to associate classes with their handlers.
      def table
        @table ||= {}
      end

    end

  end
end

%w(date date_time string symbol time uri).each do |type|
  require type.prepend 'acclaim/option/type/'
end
