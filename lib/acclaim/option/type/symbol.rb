require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles symbols given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.0.6
      module Symbol

        # Simply returns +str.to_sym+.
        def self.handle(str)
          str.to_sym
        end

      end

      accept ::Symbol, &Symbol.method(:handle)

    end
  end
end
