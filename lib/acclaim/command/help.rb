module Acclaim
  class Command

    # Module which adds help support to a command.
    module Help

      def self.create(base, opts = {})
        if opts.fetch :options, true
          switches = opts.fetch :switches, %w(-h --help)
          base.option :acclaim_help, *switches, 'Show usage information and exit.'
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
        # TODO rewrite this VERY CRUDE implementation.
        # Look into how to code a text formatter later.
        help_string = ''
        command.options.tap do |options|
          if options.any?
            help_string << "\nCommand '#{command.line}':\n\n" unless command.root?
            max = options.map { |option| option.names.join(', ').length }.max
            options.each do |option|
              switches = option.names.join ', '
              help_string << ' ' * 4 << switches << ' ' * (4 + max - switches.length)
              help_string << option.description << "\n"
            end
          end
        end
        puts help_string unless help_string.empty?
        command.subcommands.each { |subcommand| display_help_for subcommand }
      end

    end

  end
end
