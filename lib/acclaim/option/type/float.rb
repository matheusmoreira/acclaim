require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles floating point numbers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.3.0
      module Float

        # Simply returns +str.to_f+.
        def self.handle(str)
          str.to_f
        end

      end

      accept ::Float, &Float.method(:handle)

    end
  end
end
