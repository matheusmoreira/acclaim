require 'acclaim/command/help'
require 'acclaim/command/parser'
require 'acclaim/command/version'
require 'acclaim/option'
require 'acclaim/option/parser'
require 'acclaim/option/parser/regexp'
require 'ribbon'

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
      def line(*args)
        @line = args.first unless args.empty?
        @line ||= (name.gsub(/^.*::/, '').downcase rescue nil)
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
      def option(*args, &block)
        options << Option.new(*args, &block)
      end

      # Same as #option.
      alias opt option

      # The block which is executed when this command is called. It is given 2
      # parameters; the first is an Ribbon instance which can be queried for
      # settings information; the second is the remaining command line.
      def action(&block)
        @action = block
      end

      # Same as #action.
      alias when_called action

      # Adds help subcommand and options to this command.
      def help(*args)
        Help.create(self, *args)
      end

      # Adds help subcommand and options to this command.
      def version(*args)
        Version.create(self, *args)
      end

      # Parses the argument array using this command's set of options.
      def parse_options!(args)
        Option::Parser.new(args, options).parse!
      end

      # Looks for this command's subcommands in the argument array.
      def parse_subcommands!(args)
        Command::Parser.new(args, subcommands).parse!
      end

      # Invokes this command with a fresh set of option values.
      def run(*args)
        invoke Ribbon.new, args
        rescue Option::Parser::Error => e
          puts e.message
      end

      # Parses the argument array. The argument array will be searched for
      # subcommands; if one is found, it will be invoked, if not, this command
      # will be executed. A subcommand may be anywhere in the array as long as
      # it is before an argument separator, which is tipically a double dash
      # (<tt>--</tt>) and may be omitted.
      #
      # All argument separators will be deleted from the argument array before a
      # command is executed.
      def invoke(opts, args = [])
        Ribbon.merge! opts, parse_options!(args)
        handle_special_options! opts, args
        if subcommand = parse_subcommands!(args)
          subcommand.invoke(opts, args)
        else
          delete_argument_separators_in! args
          execute(opts, args)
        end
      end

      # Calls this command's action block with the given option values and
      # arguments.
      def execute(opts, args)
        @action.call opts, args if @action
      end

      # Same as #execute.
      alias call execute

      # True if this is a top-level command.
      def root?
        superclass == Acclaim::Command
      end

      # Returns all command ancestors of this command.
      def command_ancestors
        ancestors - Acclaim::Command.ancestors
      end

      # Progresively yields each command ancestor to the given block.
      def each_command_ancestor(&block)
        command_ancestors.each &block
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
      def full_line(*args)
        options = args.extract_ribbon!
        command_path.tap do |path|
          path.shift unless options.include_root?
        end.map(&:line).join ' '
      end

      private

      # Handles special options such as <tt>--help</tt> or <tt>--version</tt>.
      def handle_special_options!(opts, args)
        const_get(:Help).execute opts, args if opts.acclaim_help?
        const_get(:Version).execute opts, args if opts.acclaim_version?
      # TODO: possibly rescue a NameError and warn user
      end

      # Deletes all argument separators in the given argument array.
      def delete_argument_separators_in!(args)
        args.delete_if do |arg|
          arg =~ Option::Parser::Regexp::ARGUMENT_SEPARATOR
        end
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
