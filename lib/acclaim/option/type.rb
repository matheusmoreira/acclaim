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
      #
      # @yieldparam [Class, Module] type the class or module
      # @yieldparam [Proc] handler the type handler
      def each(&block)
        table.each &block
      end

      # Take advantage of each method.
      include Enumerable

      # Returns all registered classes.
      #
      # @return [Array<Class, Module>] registered types
      def all
        table.keys
      end

      alias registered all

      # Registers a handler for a class.
      #
      # @param [Class, Module] types the types to associate with the handler
      # @param [Proc] block the type handler
      # @yieldparam [String] string the command line argument
      # @yieldreturn [Class, Module] new object of the handled type
      def register(*types, &block)
        types.each { |type| table[type] = block }
      end

      alias add_handler_for register
      alias accept register

      # Whether the given type is registered.
      #
      # @param [Module, Class] type the type to check for registration
      # @return [true, false] whether the type is registered
      def registered?(type)
        table.has_key? type
      end

      # Returns the handler for the given class.
      #
      # @param [Class, Module] type the handler associated with the given type
      def handler_for(type)
        table.fetch type do
          raise "#{type} does not have an associated handler"
        end
      end

      alias [] handler_for

      private

      # The hash used to associate classes with their handlers.
      #
      # @return [Hash] the type handler table
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
