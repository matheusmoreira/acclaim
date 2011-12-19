module Acclaim
  class Command

    # Module which adds version query support to a command.
    module Version

      def self.create(base, version_string, opts = {})
        if opts.fetch :options, true
          switches = opts.fetch :switches, %w(-v --version)
          base.option :acclaim_version, *switches, 'Show version and exit.'
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
