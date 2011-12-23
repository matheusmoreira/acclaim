require 'acclaim/command/help/template'

module Acclaim
  class Command

    # Module which adds help support to a command.
    module Help

      def self.add_options_to!(command, opts = {})
        switches = opts.fetch :switches, %w(-h --help)
        description = opts.fetch :description, 'Show usage information and exit.'
        command.option :acclaim_help, *switches, description
      end

      private_class_method :add_options_to!

      def self.create(base, opts = {})
        if opts.fetch :options, true
          add_options_to! base, opts
        end
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
