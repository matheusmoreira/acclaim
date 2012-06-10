require 'acclaim/option/type'
require 'uri'

module Acclaim
  class Option
    module Type

      # Handles URIs given as arguments in the command line.
      module Pathname

        # Parses an +URI+ from the string.
        def self.handle(str)
          ::Pathname.new str
        end

      end

      self.accept ::Pathname, &Pathname.method(:handle)

    end
  end
end
