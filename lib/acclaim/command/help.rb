require 'acclaim/command/help/template'
require 'ribbon/core_extensions/array'

module Acclaim
  class Command

    # Module which adds help support to a command.
    module Help
    end

    class << Help

      # Creates a help subcommand that inherits from the given +base+ command
      # and stores the class in the +Help+ constant of +base+. When called, the
      # command displays a help screen including information for all commands
      # and then exits.
      #
      # @param [Acclaim::Command::DSL] base_command the command the new help
      #   subcommand will inherit from
      # @param [Hash, Ribbon, Ribbon::Raw] options method options
      # @option options [false, true] :options (true) whether help options
      #   are to be added to the base command
      # @option options [Array] :switches (['-h', '--help']) the switches of the
      #   help option
      # @option options [String, #call] :description
      #   ('Show usage information and exit.') the description of the help
      #   option
      # @option options [Array] :include_root (false) whether to include the
      #   root command in command invocation lines when displaying help
      # @option options [Acclaim::IO] :io the high-level I/O object that will be
      #   used to output the help text
      def create(base_command, options = {})
        options = Ribbon.new options

        Class.new(base_command).tap do |help_command|
          add_options_to! base_command, help_command, options if options.options? true

          help_command.when_called do
            # TODO: implement a way to specify a command to the help option
            # and command.
            #   display_for options.command || args.pop
            help_options = Ribbon.merge({ io: help_command.io }, options)

            display_for base_command.root, help_options
            exit
          end

          base_command.const_set :Help, help_command
        end
      end

      # Displays a very simple help screen for the given command and all its
      # subcommands.
      #
      # @param [Acclaim::Command::DSL] command the command to display help for
      # @param [Hash, Ribbon, Ribbon::Raw] options method options
      # @option options [Array] :include_root (false) whether to include the
      #   root command in command invocation lines
      # @option options [Acclaim::IO] :io (Acclaim::IO.standard) the high-level
      #   I/O object that will be used to output the help text
      def display_for(command, options = {})
        options = Ribbon.new options
        io = options.io? { Acclaim::IO.standard }

        io.output Help::Template.for(command, options) if command.options.any?
        command.subcommands.each { |subcommand| display_for subcommand, options }
      end

      private

      # Adds a special help option to the given +command+.
      #
      # @param [Acclaim::Command::DSL] base_command the command the new help
      #   subcommand inherited from
      # @param [Acclaim::Command::DSL] help_command the new help subcommand
      # @param [Hash, Ribbon, Ribbon::Raw] options method options
      # @option options [Array] :switches (['-h', '--help']) the switches of the
      #   help option
      # @option options [String, #call] :description
      #   ('Show usage information and exit.') the description of the help
      #   option
      def add_options_to!(base_command, help_command, options = {})
        options = Ribbon.new options
        switches = options.switches? { %w(-h --help) }
        description = options.description? { 'Show usage information and exit.' }

        base_command.option :acclaim_help, switches, description do |ribbon|
          help_command.execute ribbon
        end
      end

    end

  end
end
