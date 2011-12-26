require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles symbols given as arguments in the command line.
      module Symbol

        # Simply returns +str.to_sym+.
        def self.handle(str)
          str.to_sym
        end

      end

      self.accept ::Symbol, &Symbol.method(:handle)

    end
  end
end
