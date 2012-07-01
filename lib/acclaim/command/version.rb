require 'ribbon/core_extensions/array'

module Acclaim
  class Command

    # Module which adds version query support to a command.
    module Version
    end

    class << Version

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
      def create(base_command, version_string, options = {})
        options = Ribbon.wrap options
        Class.new(base_command).tap do |version_command|
        add_options_to! base, opts if opts.options? true
          version_command.when_called do |options, args|
            puts version_string
          end
          base_command.const_set :Version, version_command
        end
      end

      private

      # Adds a special version option to the given +command+.
      #
      # The last argument can be a configuration hash, which accepts the
      # following options:
      #
      # [:switches]  The switches used when creating the version option.
      def add_options_to!(base_command, version_command, options = {})
        options = Ribbon.wrap options
        switches = options.switches? { %w(-v --version) }
        description = options.description? { 'Show version and exit.' }
        base_command.option :acclaim_version, switches, description do |ribbon|
          version_command.execute ribbon
        end
      end

    end

  end
end
