require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles symbols given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.0.6
      module Symbol
      end

      class << Symbol

        # Converts the given string to a symbol using +to_sym+.
        #
        # @param [String] string the string to convert
        # @return [Symbol] the interned string
        def handle(string)
          string.to_sym
        end

        # No sensible default symbol.
        #
        # @return [nil] no good default value
        # @since 0.6.0
        def default
          nil
        end

      end

      accept ::Symbol, &Symbol.method(:handle)

    end
  end
end
