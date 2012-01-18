require 'acclaim/command/help/template'
require 'ribbon/core_ext/array'

module Acclaim
  class Command

    # Module which adds help support to a command.
    module Help

      # Adds a special help option to the given +command+.
      #
      # The last argument can be a configuration hash, which accepts the
      # following options:
      #
      # [:switches]  The switches used when creating the help option.
      def self.add_options_to!(*args)
        opts, command = args.extract_ribbon!, args.first
        switches = opts.switches? %w(-h --help)
        description = opts.description? 'Show usage information and exit.'
        command.option :acclaim_help, *switches, description
      end

      private_class_method :add_options_to!

      # Creates a help subcommand that inherits from the given +base+ command
      # and stores the class in the +Help+ constant of +base+. When called, the
      # command displays a help screen including information for all commands
      # and then exits.
      #
      # The last argument can be a configuration hash, which accepts the
      # following options:
      #
      # [:options]   If +true+, will add a help option to the +base+ command.
      # [:switches]  The switches used when creating the help option.
      def self.create(*args)
        opts, base = args.extract_ribbon!, args.first
        add_options_to! base, opts if opts.options? true
        base.const_set(:Help, Class.new(base)).tap do |help_command|
          help_command.when_called do |options, args|
            display_help_for base.root
            exit
          end
        end
      end

      # Displays a very simple help screen for the given command and all its
      # subcommands.
      def self.display_help_for(command)
        puts Template.for(command) if command.options.any?
        command.subcommands.each { |subcommand| display_help_for subcommand }
      end

    end

  end
end
