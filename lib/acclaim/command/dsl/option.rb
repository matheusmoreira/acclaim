%w(

acclaim/option

ribbon
ribbon/core_extensions/array

).each { |file| require file }

module Acclaim
  class Command
    module DSL

      # Module containing the methods that make up the domain-specific language
      # used to add options to a command.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.6.0
      module Option

        # The options this command can take.
        #
        # @return [Array<Acclaim::Option>] the options this command takes
        def options
          @options ||= []
        end

        # Default values for options, identified by their keys.
        #
        # @overload defaults
        #   Returns the default values identified by their option's key.
        #
        # @overload defaults(defaults)
        #   Replaces the current configuration with that of the given hash.
        #
        #   @param [Hash, Ribbon, Ribbon::Raw] defaults the default values
        #     identified by their option's key
        #
        # @return [Ribbon] default values associated with an option key
        def defaults(*arguments)
          @defaults = arguments.extract_ribbon! unless arguments.empty?
          @defaults ||= Ribbon.new
        end

        # Adds an option to this command.
        #
        # Will use the default value provided by {#defaults} if there is one
        # registered for the given option and no default value was explicitly
        # specified.
        #
        # @see Acclaim::Option#initialize
        def option(key, *arguments, &block)
          if defaults.include? key
            default = Ribbon.new default: defaults[key]
            method_options = arguments.extract_ribbon!
            arguments << default.deep_merge(method_options)
          end

          options << Acclaim::Option.new(key, *arguments, &block)
        end

        alias opt option

        # Parses the given arguments using this command's set of options.
        #
        # @param [Array<String>] arguments the argument array
        # @return [Ribbon] ribbon containing the values
        def parse_options_in!(arguments)
          Acclaim::Option::Parser.new(arguments, options).parse!
        end

      end
    end
  end
end
