require 'acclaim/command/dsl/root'

module Acclaim
  class Command

    # Module containing the methods that make up the domain-specific language
    # used to create commands.
    #
    # @author Matheus Afonso Martins Moreira
    # @since 0.4.0
    module DSL

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
        @line ||= (name.gsub(/^.*::/, '').downcase if respond_to? :name)
      end

      # Commands which may be given to this command.
      #
      # @return [Array] this command's subcommands
      def subcommands
        @subcommands ||= []
      end

      # The options this command can take.
      #
      # @return [Array] the options this command takes
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

      # The block which is executed when this command is called.
      #
      # @yieldparam [Ribbon] options a Ribbon instance which associates options
      #   with their corresponding values
      # @yieldparam [Array] arguments the arguments that remained in the command
      #   line
      # @return [Proc, nil] the given block
      def action(&block)
        @action = block if block.respond_to? :call
        @action
      end

      alias when_called action

      # Parses the argument array using this command's set of options.
      def parse_options_in!(arguments)
        Option::Parser.new(arguments, options).parse!
      end

      # Looks for this command's subcommands in the argument array.
      def parse_subcommands_in!(arguments)
        Command::Parser.new(arguments, subcommands).parse!
      end

      # Invokes this command with a fresh set of option values.
      def run(*arguments)
        invoke arguments
      rescue Option::Parser::Error => error
        $stderr.puts error.message
      end

      # Parses the argument array. The argument array will be searched for
      # subcommands; if one is found, it will be invoked, if not, this command
      # will be executed. A subcommand may be anywhere in the array as long as
      # it is before an argument separator, which is tipically a double dash
      # (<tt>--</tt>) and may be omitted.
      #
      # All argument separators will be deleted from the argument array before a
      # command is executed.
      def invoke(arguments = [], options = {})
        options = Ribbon.wrap options
        options.merge! parse_options!(arguments)
        handle_special_options! options, arguments
        if subcommand = parse_subcommands!(arguments)
          subcommand.invoke arguments, options
        else
          delete_argument_separators_in! arguments
          execute options, arguments
        end
      end

      # Calls this command's action block with the given option values and
      # arguments.
      def execute(options, arguments)
        @action.call options, arguments if @action.respond_to? :call
      end

      alias call execute

      # True if this is a top-level command.
      def root?
        superclass == Acclaim::Command
      end

      # Returns all command ancestors of this command.
      def command_ancestors
        ancestors - Acclaim::Command.ancestors
      end

      # Returns the root of the command hierarchy.
      def root
        command_ancestors.last
      end

      # Returns the sequence of commands from #root that leads to this command.
      def command_path
        command_ancestors.reverse
      end

      # Computes the full command line of this command, which takes parent
      # commands into account.
      #
      #   class Command < Acclaim::Command
      #     class Do < Command
      #       class Something < Do
      #       end
      #     end
      #   end
      #
      #   Command::Do::Something.full_line
      #    => "do something"
      #
      #   Command::Do::Something.full_line include_root: true
      #    => "command do something"
      def full_line(*arguments)
        options = arguments.extract_ribbon!
        command_path.tap do |path|
          path.shift unless options.include_root?
        end.map(&:line).join ' '
      end

      private

      # Handles special options such as <tt>--help</tt> or <tt>--version</tt>.
      def handle_special_options!(options, arguments)
        const_get(:Help).execute options, arguments if options.acclaim_help?
        const_get(:Version).execute options, arguments if options.acclaim_version?
      # TODO:
      #   possibly rescue a NameError and warn user
      #   fix bug:
      #     calling this method causes a subcommand to be executed even if it
      #     wasn't given on the command line. This may result up to **three**
      #     commands (help, version and the actual command) running in one
      #     invocation.
      end

      # Deletes all argument separators in the given argument array.
      def delete_argument_separators_in!(arguments)
        arguments.delete_if do |arg|
          arg =~ Option::Parser::Regexp::ARGUMENT_SEPARATOR
        end
      end

      include Root

    end

  end
end
