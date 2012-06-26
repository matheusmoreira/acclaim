require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles floating point numbers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.0
      module Float
      end

      class << Float

        # Uses Float() to convert the string to a floating-point number.
        #
        # @param [String] the string to be converted
        # @return [Float] the floating-point number converted from the string
        def handle(string)
          Float(string)
        end

        # Default value of zero.
        #
        # @return [Float] zero
        # @since 0.6.0
        def default
          0.0
        end

      end

      accept ::Float, &Float.method(:handle)

    end
  end
end
