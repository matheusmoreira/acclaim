%w(

acclaim/command/dsl/help
acclaim/command/dsl/io
acclaim/command/dsl/option
acclaim/command/dsl/version
acclaim/command/parser
acclaim/io
acclaim/option/parser
acclaim/option/parser/regexp

ribbon
ribbon/core_extensions/object

).each { |file| require file }

module Acclaim
  class Command

    # Module containing the methods that make up the domain-specific language
    # used to create commands.
    #
    # @author Matheus Afonso Martins Moreira
    # @since 0.4.0
    module DSL

      [

        Help,
        IO,
        Option,
        Version

      ].each { |dsl| include dsl }

      # The string used to invoke this command from the command line.
      #
      # @overload line
      #   If not set, will try to figure out the name from the command's class.
      #
      #   @return [String] the name used to invoke this command
      #
      # @overload line(string)
      #   Uses the given string to invoke this command.
      #
      #   @param [String, nil] string the new command name
      #   @return [String] the name used to invoke this command
      def line(*arguments)
        @line = arguments.first unless arguments.empty?
        @line ||= begin name.gsub(/^.*::/, '').downcase rescue NoMethodError nil end
      end

      # Commands which may be given to this command.
      #
      # @return [Array<Acclaim::Command::DSL>] this command's subcommands
      def subcommands
        @subcommands ||= []
      end

      # The block which is executed when this command is called.
      #
      # @yieldparam [Ribbon] options a ribbon instance which associates options
      #   with their corresponding values
      # @yieldparam [Array<String>] arguments the arguments that remained in the
      #   command line
      # @return [Proc, nil] the given block
      def action(&block)
        @action = block if block.respond_to? :call
        @action
      end

      alias when_called action

      # The high-level input/output interface used by this command.
      #
      # @overload io
      #   If not set, will use the standard streams.
      #
      #   @return [Acclaim::IO] the high-level I/O interface
      #   @see Acclaim::IO.standard
      #
      # @overload io(interface)
      #   Sets this command's high-level I/O interface.
      #
      #   @param [Acclaim::IO] interface the high-level I/O interface
      #   @return [Acclaim::IO] the given I/O interface
      #   @example
      #     io = Acclaim::IO.new output: nil, error: nil
      #     Some::Command.terminal io
      def io(*arguments)
        @io = arguments.first unless arguments.empty?
        @io ||= Acclaim::IO.standard
      end

      alias shell io
      alias terminal io

      # Searches the given arguments for one of this command's subcommands.
      #
      # @param [Array<String>] arguments the argument array
      # @return [Acclaim::Command::DSL, nil] a subcommand of this command or nil
      #   if there was no match
      def parse_subcommands_in!(arguments)
        Command::Parser.new(arguments, subcommands).parse!
      end

      # Invokes this command with the given arguments. Outputs
      # {Option::Parser::Error parser error} messages to the standard error
      # stream.
      #
      # @param [Array<String>] arguments the argument array
      # @see #invoke
      def run(*arguments)
        invoke arguments
      rescue Acclaim::Option::Parser::Error => parser_error
        error parser_error.message
      end

      # Searches the given arguments for subcommands and {#invoke invokes} it.
      # If none were found, {#execute executes} this command instead.
      #
      # The arguments will be parsed using all options from {#command_ancestors
      # this command and its parents}.
      #
      # @note Argument separators will be deleted prior to command execution.
      #
      # @param [Array<String>] arguments the argument array
      def invoke(arguments = [])
        subcommand = parse_subcommands_in! arguments
        if subcommand.nil?
          all_options = command_ancestors.collect(&:options).flatten
          parsed_options = Acclaim::Option::Parser.new(arguments, all_options).parse!
          delete_argument_separators_in! arguments
          execute parsed_options, arguments
        else
          subcommand.invoke arguments
        end
      end

      # Calls this command's {#action action block} with the given option values
      # and arguments.
      #
      # @param [Ribbon] options ribbon containing options and values
      # @param [Array<String>] arguments additional arguments to the program
      def execute(options, arguments = [])
        action.instance_eval do
          call options, arguments if respond_to? :call
        end
      end

      alias call execute

      # Returns all command ancestors of this command.
      #
      # @return [Array<Acclaim::Command::DSL] this command's parent commands
      def command_ancestors
        ancestors - Acclaim::Command.ancestors
      end

      # Returns the root of the command hierarchy.
      #
      # @return [Acclaim::Command::DSL] the top-level command
      def root
        command_ancestors.last
      end

      # Whether this is a top-level command.
      #
      # @return [true, false] whether this command is at the root of the
      #   hierarchy
      def root?
        self == root
      end

      # Returns the sequence of commands from #root that leads to this command.
      #
      # @return [Array<Acclaim::Command::DSL>] the path to this command
      def command_path
        command_ancestors.reverse
      end

      # Computes the full command line of this command, taking parent commands
      # into account.
      #
      # @param [Hash, Ribbon, Ribbon::Raw] options method options
      # @option options [true, false] :include_root (false) whether to include
      #   the {#root root} command in the full command line
      #
      # @example
      #   class Command < Acclaim::Command
      #     class Do < Command
      #       class Something < Do
      #       end
      #     end
      #   end
      #
      #   Command::Do::Something.full_line
      #   # => "do something"
      #
      #   Command::Do::Something.full_line include_root: true
      #   # => "command do something"
      def full_line(options = {})
        options = Ribbon.new options
        command_path.tap do |path|
          path.shift unless options.include_root?
        end.map(&:line).join ' '
      end

      private

      # Deletes all argument separators in the given argument array.
      def delete_argument_separators_in!(arguments)
        arguments.delete_if do |arg|
          arg =~ Acclaim::Option::Parser::Regexp::ARGUMENT_SEPARATOR
        end
      end

    end

  end
end
