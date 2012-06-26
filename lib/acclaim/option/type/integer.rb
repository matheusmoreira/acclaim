require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles integers given as arguments in the command line.
      #
      # @author Matheus Afonso Martins Moreira
      module Integer

        # Simply returns +str.to_i+.
        def self.handle(str)
          str.to_i
        end

      end

      self.accept ::Integer, &Integer.method(:handle)

    end
  end
end
