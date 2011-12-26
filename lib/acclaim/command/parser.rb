require 'acclaim/option/parser/regexp'

module Acclaim
  class Command

    # Given an argument array and a list of commands, searches for them among
    # the elements of the array.
    class Parser

      attr_accessor :argv, :commands

      # Initializes a new command parser, with the given argument array and set
      # of commands to search for.
      def initialize(argv, commands)
        self.argv = argv
        self.commands = commands
      end

      # Parses the argument array and returns one of the given commands, if one
      # is found, or +nil+ otherwise.
      def parse!
        slice_argv_on_separator
        find_command
      end

      private

      # Discards all elements in the argument array after and including the
      # argument separator, if one exists.
      def slice_argv_on_separator
        self.argv = argv.take_while do |arg|
          arg !~ Option::Parser::Regexp::ARGUMENT_SEPARATOR
        end
      end

      # Searches for one of the given commands in the argument array, and
      # returns it. If no commands were found, +nil+ is returned.
      def find_command
        commands.find do |command|
          argv.include? command.line
        end.tap do |command|
          argv.delete command.line if command
        end
      end

    end

  end
end