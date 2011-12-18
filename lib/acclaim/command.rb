require 'acclaim/option'
require 'acclaim/option/parser'
require 'acclaim/options'

module Acclaim

  # A command is a single word whose meaning the program understands. It calls
  # upon a function of the program, which may be fine-tuned with options and
  # given arguments.
  #
  #   app --global-option do --option
  #
  # A subcommand benefits from its parent's option processing.
  #
  #   app do something --option --option-for-something
  #
  # A command can be instantiated in the following form:
  #
  #   class App::Command < Acclaim::Command
  #     opt :verbose, names: %w(-v --verbose), description: 'Run verbosely'
  #   end
  #
  # A subcommand can be created by inheriting from another command:
  #
  #   class App::Command::Do < App::Command
  #     opt :what, names: %w(-W --what), description: 'Do what?', arity: [1, 0], required: true
  #     when_called do |options, arguments|
  #       puts "Verbose? #{options.verbose? ? 'yes' : 'no'}"
  #       puts "Doing #{options.what} with #{arguments.inspect} now!"
  #     end
  #   end
  #
  # Then, in your application's binary, you may simply write:
  #
  #   App::Command.run *ARGV
  #
  # Subcommands inherit their parent's option processing:
  #
  #   $ app --verbose -W test do arg1 arg2
  #   Verbose? yes
  #   Doing test with ["arg1", "arg2"] now!
  class Command

    # Module containing the class methods every command class should inherit.
    module ClassMethods

      # String which calls this command.
      def line(value = nil)
        @line = value if value
        @line
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
      def option(key, args = {})
        args.merge!(key: key)
        options << Option.new(args)
      end

      alias :opt :option

      # The block which is executed when this command is called. It is given 2
      # parameters; the first is an Options instance which can be queried for
      # settings information; the second is the remaining command line.
      def action(&block)
        @action = block
      end

      alias :when_called :action

      # Parses the argument array using this command's set of options.
      def parse_options!(args)
        Option::Parser.new(args, options).parse!
      end

      # Invokes this command with a fresh set of options.
      def run(*args)
        invoke Options.new, args
        rescue Option::Parser::Error => e
          puts e.message
      end

      # Parses the argument array. If the first element of the argument array
      # corresponds to a subcommand, it will be invoked with said array and
      # with this command's parsed options. This command will be executed
      # otherwise.
      def invoke(opts, args = [])
        opts.merge! parse_options!(args)
        arg_separator = args.find { |arg| arg =~ Option::Parser::ARGUMENT_SEPARATOR }
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

    end

    # Add the class methods to the subclass and add it to this command's list of
    # subcommands.
    def self.inherited(sub)
      sub.extend ClassMethods
      sub.line sub.name.gsub(/^.*::/, '').downcase
      subcommands << sub if respond_to? :subcommands
    end

  end

end
