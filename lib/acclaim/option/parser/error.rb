module Acclaim
  class Option
    class Parser

      # Errors raised by the parser.
      class Error < StandardError

        # Raises an Error with the following error message:
        #
        #   Wrong number of arguments (#{actual} for #{minimum})
        def self.raise_wrong_arg_number(actual, minimum, optional)
          raise self, "Wrong number of arguments (#{actual} for #{minimum})"
        end

        # Raises an Error with the following error message:
        #
        #   Missing required argument (#{option.names.join '|'})
        def self.raise_missing_required(option)
          names = option.names.join '|'
          raise self, "Missing required argument (#{names})"
        end

        # Raises an error with the following error message:
        #
        #   Multiple instances of [#{options.names.join ''}] encountered
        def self.raise_multiple(option)
          names = option.names.join '|'
          raise self, "Multiple instances of [#{names}] encountered"
        end

      end

    end
  end
end
