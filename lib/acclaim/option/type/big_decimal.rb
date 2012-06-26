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

        # Returns +BigDecimal.new(str)+.
        def handle(string)
          ::BigDecimal.new string
        end

      end

      accept ::BigDecimal, &BigDecimal.method(:handle)

    end
  end
end
