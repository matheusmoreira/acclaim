require 'acclaim/command/help'
require 'acclaim/command/version'
require 'acclaim/option'
require 'acclaim/option/parser'
require 'acclaim/option/parser/regexp'
require 'acclaim/option/values'

module Acclaim

  # A command is a single word whose meaning the program understands. It calls
  # upon a function of the program, which may be fine-tuned with options and
  # given arguments.
  #
  #   app --global-option do --option
  #
  # A subcommand benefits from its parent's option processing.
  #
  #   app --global-option do something --option-for-do --option-for-something
  #
  # A command can be created in the following form:
  #
  #   class App::Command < Acclaim::Command
  #     option :verbose, '-v', '--verbose', 'Run verbosely'
  #   end
  #
  # A subcommand can be created by inheriting from another command:
  #
  #   class App::Command::Do < App::Command
  #     opt :what, '-W', '--what', 'What to do', arity: [1, 0], required: true
  #     when_called do |options, arguments|
  #       puts "Verbose? #{options.verbose? ? :yes : :no}"
  #       puts "Doing #{options.what} with #{arguments.join ' and ')}!"
  #     end
  #   end
  #
  # Then, in your application's binary, you may simply write:
  #
  #   App::Command.run *ARGV
  #
  # See it in action:
  #
  #   $ app --verbose do --what testing acclaim safeguard
  #   Verbose? yes
  #   Doing testing with acclaim and safeguard!
  class Command

    # Module containing the class methods every command class should inherit.
    module ClassMethods

      # String which calls this command.
      def line(value = nil)
        @line = value
        @line ||= name.gsub(/^.*::/, '').downcase
      end

      # Commands which may be given to this command.
      def subcommands
        @subcommands ||= []
      end

      # The options this command can take.
      def options
        @options ||= []
      end

      # Adds an option to this command.
      def option(*args)
        options << Option.new(*args)
      end

      alias :opt :option

      # The block which is executed when this command is called. It is given 2
      # parameters; the first is an Options instance which can be queried for
      # settings information; the second is the remaining command line.
      def action(&block)
        @action = block
      end

      alias :when_called :action

      def add_help
        subcommands << Help.create(self)
      end

      def version(version_string, opts = {})
        subcommands << Version.create(self, version_string, opts)
      end

      # Parses the argument array using this command's set of options.
      def parse_options!(args)
        Option::Parser.new(args, options).parse!
      end

      # Invokes this command with a fresh set of options.
      def run(*args)
        invoke Option::Values.new, args
        rescue Option::Parser::Error => e
          puts e.message
      end

      # Parses the argument array. If the first element of the argument array
      # corresponds to a subcommand, it will be invoked with said array and
      # with this command's parsed options. This command will be executed
      # otherwise.
      def invoke(opts, args = [])
        opts.merge! parse_options!(args)
        handle_special_options! opts, args
        arg_separator = args.find do |arg|
          arg =~ Option::Parser::Regexp::ARGUMENT_SEPARATOR
        end
        separator_index = args.index arg_separator
        subcommands.find do |subcommand|
          index = args.index subcommand.line
          # If we have the subcommand AND the separator, then we have it if the
          # subcommand is before the separator.
          index and (not separator_index or index < separator_index)
        end.tap do |subcommand|
          if subcommand
            args.delete subcommand.line
            subcommand.invoke(opts, args)
          else
            execute(opts, args)
          end
        end
      end

      # Calls this command's action block with the given options and arguments.
      def execute(opts, args)
        @action.call opts, args
      end

      alias :call :execute

      def root?
        superclass == Acclaim::Command
      end

      def root
        command = self
        command = command.superclass until command.root?
        command
      end

      private

      # Handles special options such as <tt>--help</tt> or <tt>--version</tt>.
      def handle_special_options!(opts, args)
        const_get(:Help).execute opts, args if opts.help?
        const_get(:Version).execute opts, args if opts.acclaim_version?
      end

    end

    # Add the class methods to the subclass and add it to this command's list of
    # subcommands.
    def self.inherited(sub)
      sub.extend ClassMethods
      subcommands << sub if respond_to? :subcommands
    end

  end

end
