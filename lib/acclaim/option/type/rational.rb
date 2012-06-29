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
        # @return [Rational] the rational number
        def handle(string)
          Rational(string)
        end

        # Rational representation of 0.
        #
        # @return [Rational] 0 as a rational object
        # @since 0.6.0
        def default
          Rational(0)
        end

      end

      accept ::Rational, &Rational.method(:handle)

    end
  end
end
