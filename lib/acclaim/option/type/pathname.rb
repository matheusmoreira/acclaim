require 'acclaim/option/type'
require 'pathname'

module Acclaim
  class Option
    module Type

      # Handles file and directory paths given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.1
      module Pathname
      end

      class << Pathname

        # Parses an +URI+ from the string.
        def handle(string)
          ::Pathname.new string
        end

      end

      accept ::Pathname, &Pathname.method(:handle)

    end
  end
end
