require 'acclaim/option/type'
require 'uri'

module Acclaim
  class Option
    module Type

      # Handles URIs given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.1
      module Pathname

        # Parses an +URI+ from the string.
        def self.handle(str)
          ::Pathname.new str
        end

      end

      accept ::Pathname, &Pathname.method(:handle)

    end
  end
end
