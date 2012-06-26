require 'acclaim/option/type'
require 'uri'

module Acclaim
  class Option
    module Type

      # Handles URIs given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      module URI

        # Parses an +URI+ from the string.
        def self.handle(str)
          ::URI.parse str
        end

      end

      self.accept ::URI, &URI.method(:handle)

    end
  end
end
