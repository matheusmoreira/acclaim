require 'acclaim/option/type'
require 'date'

module Acclaim
  class Option
    module Type

      # Handles dates given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      module Date

        # Parses a +Date+ from the string.
        def self.handle(str)
          ::Date.parse str
        end

      end

      accept ::Date, &Date.method(:handle)

    end
  end
end
