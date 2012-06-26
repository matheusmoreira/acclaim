require 'acclaim/option/type'
require 'date'

module Acclaim
  class Option
    module Type

      # Handles dates given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      module Date
      end

      class << Date

        # Parses a +Date+ from the string.
        def handle(string)
          ::Date.parse string
        end

      end

      accept ::Date, &Date.method(:handle)

    end
  end
end
