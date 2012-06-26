require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles complex numbers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.0
      module Complex

        # Simply returns +str.to_c+.
        def self.handle(str)
          str.to_c
        end

      end

      accept ::Complex, &Complex.method(:handle)

    end
  end
end
