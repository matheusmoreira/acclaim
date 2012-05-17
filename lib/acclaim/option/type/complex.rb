require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles complex numbers given as arguments in the command line.
      module Complex

        # Simply returns +str.to_c+.
        def self.handle(str)
          str.to_c
        end

      end

      self.accept ::Complex, &Complex.method(:handle)

    end
  end
end
