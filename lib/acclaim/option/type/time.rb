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
        def handle(str)
          ::Time.parse str
        end

      end

      self.accept ::Time, &Time.method(:handle)

    end
  end
end
