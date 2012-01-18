require 'ribbon/core_ext/array'

module Acclaim
  class Command

    # Module which adds version query support to a command.
    module Version

      # The class methods.
      class << self

        # Creates a <tt>version</tt> subcommand that inherits from the given
        # +base+ command and stores the class in the +Version+ constant of +base+.
        # When called, the command displays the +version_string+ of the program
        # and then exits.
        #
        # The last argument can be a configuration hash, which accepts the
        # following options:
        #
        # [:options]   If +true+, will add a version option to the +base+ command.
        # [:switches]  The switches used when creating the version option.
        def create(*args)
          opts, base, version_string = args.extract_ribbon!, args.shift, args.shift
          add_options_to! base, opts if opts.options? true
          base.const_set(:Version, Class.new(base)).tap do |version_command|
            version_command.when_called do |options, args|
              puts version_string
              exit
            end
          end
        end

        private

        # Adds a special version option to the given +command+.
        #
        # The last argument can be a configuration hash, which accepts the
        # following options:
        #
        # [:switches]  The switches used when creating the version option.
        def add_options_to!(*args)
          opts, command = args.extract_ribbon!, args.shift
          switches = opts.switches? %w(-v --version)
          description = opts.description? 'Show version and exit.'
          command.option :acclaim_version, *switches, description
        end

      end

    end

  end
end
