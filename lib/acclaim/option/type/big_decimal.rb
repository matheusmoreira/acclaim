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
        def self.handle(str)
          ::BigDecimal.new str
        end

      end

      accept ::BigDecimal, &BigDecimal.method(:handle)

    end
  end
end
