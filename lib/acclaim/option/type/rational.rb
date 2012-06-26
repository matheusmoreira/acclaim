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

        # Simply returns +str.to_r+.
        def handle(str)
          str.to_r
        end

      end

      accept ::Rational, &Rational.method(:handle)

    end
  end
end
