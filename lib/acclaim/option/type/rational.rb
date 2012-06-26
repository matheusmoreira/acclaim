require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles rational numbers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.0
      module Rational
      end

      class << Rational

        # Uses Rational() to coerce the string to a Rational number.
        #
        # @param [String] string string representation of the number or fraction
        # @param [Rational] the rational number
        def handle(string)
          Rational(string)
        end

      end

      accept ::Rational, &Rational.method(:handle)

    end
  end
end
