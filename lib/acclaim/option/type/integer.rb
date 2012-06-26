require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles integers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.0
      module Integer
      end

      class << Integer

        # Simply returns +str.to_i+.
        def handle(str)
          str.to_i
        end

      end

      accept ::Integer, &Integer.method(:handle)

    end
  end
end
