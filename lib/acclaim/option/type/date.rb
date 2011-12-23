require 'acclaim/option/type'
require 'date'

module Acclaim
  class Option
    module Type

      # Handles dates given as arguments in the command line.
      module Date

        def self.handle(str)
          ::Date.parse str
        end

      end

      self.accept ::Date, &Date.method(:handle)

    end
  end
end
