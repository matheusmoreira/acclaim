require 'acclaim/option/type'
require 'time'

module Acclaim
  class Option
    module Type

      # Handles times given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      module Time
      end

      class << Time

        # Parses a +Time+ from the string.
        #
        # @param [String] string the string to be parsed
        # @return [Time] the time parsed from the string
        def handle(string)
          ::Time.parse string
        end

      end

      accept ::Time, &Time.method(:handle)

    end
  end
end
