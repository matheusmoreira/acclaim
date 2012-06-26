require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles complex numbers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.0
      module Complex
      end

      class << Complex

        # Simply returns +str.to_c+.
        def handle(string)
          string.to_c
        end

      end

      accept ::Complex, &Complex.method(:handle)

    end
  end
end
