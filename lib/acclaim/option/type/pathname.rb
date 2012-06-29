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

        # Parses the path string.
        #
        # @param [String] string the string containing the path
        # @return [Pathname] the pathname
        def handle(string)
          ::Pathname.new string
        end

        # Path to the current working directory.
        #
        # @return [Pathname] path to the working directory
        # @since 0.6.0
        def default
          ::Pathname.pwd
        end

      end

      accept ::Pathname, &Pathname.method(:handle)

    end
  end
end
