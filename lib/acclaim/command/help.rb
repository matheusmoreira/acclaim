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
      # The last argument can be a configuration hash, which accepts the
      # following options:
      #
      # [:options]       If +true+, will add a help option to the +base+
      #                  command.
      # [:switches]      The switches used when creating the help option.
      # [:include_root]  Includes the root command when displaying a command's
      #                  usage.
      def create(base_command, options = {})
        options = Ribbon.wrap options
        Class.new(base_command).tap do |help_command|
          add_options_to! base_command, help_command, options if options.options? true
          help_command.when_called do |options, args|
            # TODO: implement a way to specify a command to the help option
            # and command.
            #   display_for options.command || args.pop
            display_for base_command.root, options
            exit
          end
          base_command.const_set :Help, help_command
        end
      end

      # Displays a very simple help screen for the given command and all its
      # subcommands.
      #
      # The last argument can be a configuration hash, which accepts the
      # following options:
      #
      # [:include_root]  Includes the root command when displaying a command's
      #                  usage.
      def display_for(*args)
        options, command = args.extract_ribbon!, args.shift
        puts Help::Template.for(command, options) if command.options.any?
        command.subcommands.each { |subcommand| display_for(subcommand, options) }
      end

      private

      # Adds a special help option to the given +command+.
      #
      # The last argument can be a configuration hash, which accepts the
      # following options:
      #
      # [:switches]  The switches used when creating the help option.
      def add_options_to!(base_command, help_command, options = {})
        options = Ribbon.wrap options
        switches = options.switches? { %w(-h --help) }
        description = options.description? { 'Show usage information and exit.' }
        base_command.option :acclaim_help, switches, description do |ribbon|
          help_command.execute ribbon
        end
      end

    end

  end
end
