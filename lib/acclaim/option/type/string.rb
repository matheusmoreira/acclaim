require 'acclaim/option/type'

module Acclaim
  class Option
    module Type

      # Handles strings given as arguments in the command line.
      module String

        # Simply returns +str.to_s+.
        def self.handle(str)
          str.to_s
        end

      end

      self.accept ::String, &String.method(:handle)

    end
  end
end
