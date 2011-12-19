module Acclaim
  class Command

    # Module which adds version query support to a command.
    module Version

      def self.add_options_to!(command, opts = {})
        switches = opts.fetch :switches, %w(-v --version)
        description = opts.fetch :description, 'Show version and exit.'
        command.option :acclaim_version, *switches, description
      end

      private_class_method :add_options_to!

      def self.create(base, version_string, opts = {})
        if opts.fetch :options, true
          add_options_to! base, opts
        end
        base.const_set(:Version, Class.new(base)).tap do |version_command|
          version_command.when_called do |options, args|
            puts version_string
            exit
          end
        end
      end

    end

  end
end
