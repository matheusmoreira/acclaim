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
        #
        # @param [String] string the string to be parsed
        # @return [Date] the date and time parsed from the string
        def handle(string)
          ::Date.parse string
        end

        # Today's date.
        #
        # @return [Date] today's local date
        # @since 0.6.0
        def default
          Date.today
        end

      end

      accept ::Date, &Date.method(:handle)

    end
  end
end
