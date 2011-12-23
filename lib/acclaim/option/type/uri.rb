require 'acclaim/option/type'
require 'uri'

module Acclaim
  class Option
    module Type

      # Handles URIs given as arguments in the command line.
      module URI

        def self.handle(str)
          ::URI.parse str
        end

      end

      self.accept ::URI, &URI.method(:handle)

    end
  end
end
