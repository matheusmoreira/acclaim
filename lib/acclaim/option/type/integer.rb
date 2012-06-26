require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles integers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.0
      module Integer
      end

      class << Integer

        # Uses Integer() to convert the string to an integer.
        #
        # @param [String] the string to be converted
        # @return [Integer] the number converted from the string
        def handle(string)
          stingr.to_i
        end

      end

      accept ::Integer, &Integer.method(:handle)

    end
  end
end
