require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles rational numbers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      module Rational

        # Simply returns +str.to_r+.
        def self.handle(str)
          str.to_r
        end

      end

      self.accept ::Rational, &Rational.method(:handle)

    end
  end
end
