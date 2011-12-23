require 'acclaim/option/type'
require 'time'

module Acclaim
  class Option
    module Type

      # Handles strings given as arguments in the command line.
      module String

        def self.handle(str)
          str.to_s
        end

      end

      self.accept ::String, &String.method(:handle)

    end
  end
end
