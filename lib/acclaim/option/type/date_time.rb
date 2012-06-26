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
        #
        # @param [String] string the string to be parsed
        # @return [DateTime] the date and time parsed from the string
        def handle(string)
          ::DateTime.parse string
        end

        # Current date and time.
        #
        # @return [DateTime] current local date and time
        # @since 0.6.0
        def default
          ::DateTime.now
        end

      end

      accept ::DateTime, &DateTime.method(:handle)

    end
  end
end
