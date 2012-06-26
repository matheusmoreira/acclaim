require 'acclaim/option/type'
require 'date'

module Acclaim
  class Option
    module Type

      # Handles dates and times given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      module DateTime
      end

      class << DateTime

        # Parses a +DateTime+ from the string.
        def self.handle(str)
          ::DateTime.parse str
        end

      end

      accept ::DateTime, &DateTime.method(:handle)

    end
  end
end
