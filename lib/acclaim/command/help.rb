require 'acclaim/command/help/template'
require 'ribbon/core_ext/array'

module Acclaim
  class Command

    # Module which adds help support to a command.
    module Help

      # The class methods.
      class << self

        # Creates a help subcommand that inherits from the given +base+ command
        # and stores the class in the +Help+ constant of +base+. When called,
        # the command displays a help screen including information for all
        # commands and then exits.
        #
        # The last argument can be a configuration hash, which accepts the
        # following options:
        #
        # [:options]       If +true+, will add a help option to the +base+
        #                  command.
        # [:switches]      The switches used when creating the help option.
        # [:include_root]  Includes the root command when displaying a command's
        #                  usage.
        def create(*args)
          opts, base = args.extract_ribbon!, args.first
          add_options_to! base, opts if opts.options? true
          base.const_set(:Help, Class.new(base)).tap do |help_command|
            help_command.when_called do |options, args|
              display_for base.root, opts
              exit
            end
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
          puts Template.for(command, options) if command.options.any?
          command.subcommands.each { |subcommand| display_for(subcommand, options) }
        end

        private

        # Adds a special help option to the given +command+.
        #
        # The last argument can be a configuration hash, which accepts the
        # following options:
        #
        # [:switches]  The switches used when creating the help option.
        def add_options_to!(*args)
          opts, command = args.extract_ribbon!, args.first
          switches = opts.switches? %w(-h --help)
          description = opts.description? 'Show usage information and exit.'
          command.option :acclaim_help, *switches, description
        end

      end

    end

  end
end
