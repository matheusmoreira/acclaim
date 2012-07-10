%w(

acclaim/option

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

        # Adds an option to this command.
        #
        # @see Acclaim::Option#initialize
        def option(*arguments, &block)
          options << Option.new(*arguments, &block)
        end

        alias opt option

        # Parses the given arguments using this command's set of options.
        #
        # @param [Array<String>] arguments the argument array
        # @return [Ribbon] ribbon containing the values
        def parse_options_in!(arguments)
          Option::Parser.new(arguments, options).parse!
        end

      end
    end
  end
end
