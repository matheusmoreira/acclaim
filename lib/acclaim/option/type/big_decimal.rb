require 'acclaim/option/type'
require 'bigdecimal'

module Acclaim
  class Option
    module Type

      # Handles big decimals given as arguments in the command line.
      module BigDecimal

        # Returns +BigDecimal.new(str)+.
        def self.handle(str)
          ::BigDecimal.new str
        end

      end

      self.accept ::BigDecimal, &BigDecimal.method(:handle)

    end
  end
end
