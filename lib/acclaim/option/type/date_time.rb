require 'acclaim/option/type'
require 'date'

module Acclaim
  class Option
    module Type

      # Handles dates and times given as arguments in the command line.
      module DateTime

        def self.handle(str)
          ::DateTime.parse str
        end

      end

      self.accept ::DateTime, &DateTime.method(:handle)

    end
  end
end
