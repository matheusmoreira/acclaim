require 'acclaim/option/type'
require 'uri'

module Acclaim
  class Option
    module Type

      # Handles URIs given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      module URI
      end

      class << URI

        # Parses an +URI+ from the string.
        #
        # @param [String] string the string to be parsed
        # @return [URI] URI parsed from the string
        def handle(string)
          ::URI.parse string
        end

      end

      self.accept ::URI, &URI.method(:handle)

    end
  end
end
