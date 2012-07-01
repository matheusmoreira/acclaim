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
      # @param [Acclaim::Command::DSL] base_command the command the new version
      #   subcommand will inherit from
      # @param [Hash, Ribbon, Ribbon::Wrapper] options method options
      # @option options [false, true] :options (true) whether version options
      #   are to be added to the base command
      # @option options [Array] :switches (['-v', '--version']) the switches of
      #   the version option
      # @option options [String, #call] :description ('Show version and exit.')
      #   the description of the version option
      def create(base_command, version_string, options = {})
        options = Ribbon.wrap options
        Class.new(base_command).tap do |version_command|
          add_options_to! base_command, version_command, options if options.options? true
          version_command.when_called do
            puts version_string
            exit
          end
          base_command.const_set :Version, version_command
        end
      end

      private

      # Adds a special version option to the given +command+.
      #
      # @param [Acclaim::Command::DSL] base_command the command the new version
      #   subcommand will inherit from
      # @param [Acclaim::Command::DSL] version_command the new version
      #   subcommand
      # @param [Hash, Ribbon, Ribbon::Wrapper] options method options
      # @option options [Array] :switches (['-v', '--version']) the switches of
      #   the version option
      # @option options [String, #call] :description ('Show version and exit.')
      #   the description of the version option
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
