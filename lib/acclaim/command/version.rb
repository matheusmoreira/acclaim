module Acclaim
  class Command

    # Module which adds version query support to a command.
    module Version

      # Adds a special version option to the given +command+.
      #
      # The last argument is an option +Hash+, which accepts the following
      # options:
      #
      # [:switches]  The switches used when creating the version option.
      def self.add_options_to!(command, opts = {})
        switches = opts.fetch :switches, %w(-v --version)
        description = opts.fetch :description, 'Show version and exit.'
        command.option :acclaim_version, *switches, description
      end

      private_class_method :add_options_to!

      # Creates a <tt>version</tt> subcommand that inherits from the given
      # +base+ command and stores the class in the +Version+ constant of +base+.
      # When called, the command displays the +version_string+ of the program
      # and then exits.
      #
      # The last argument is an option +Hash+, which accepts the following
      # options:
      #
      # [:options]   If +true+, will add a version option to the +base+ command.
      # [:switches]  The switches used when creating the version option.
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
