require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles floating point numbers given as arguments in the command line.
      module Float

        # Simply returns +str.to_f+.
        def self.handle(str)
          str.to_f
        end

      end

      self.accept ::Float, &Float.method(:handle)

    end
  end
end
