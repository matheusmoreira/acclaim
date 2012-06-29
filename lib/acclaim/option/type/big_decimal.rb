require 'acclaim/option/type'
require 'bigdecimal'

module Acclaim
  class Option
    module Type

      # Handles big decimals given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.0
      module BigDecimal
      end

      class << BigDecimal

        # Creates a new +BigDecimal+ using the string.
        #
        # @param [String] string the string representation of the decimal number
        # @return [BigDecimal] the object representing the decimal number
        def handle(string)
          ::BigDecimal.new string
        end

        # Zero as big decimal.
        #
        # @return [BigDecimal] zero as a big decimal
        # @since 0.6.0
        def default
          ::BigDecimal.new 0
        end

      end

      accept ::BigDecimal, &BigDecimal.method(:handle)

    end
  end
end
