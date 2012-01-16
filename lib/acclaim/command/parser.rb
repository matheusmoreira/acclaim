require 'acclaim/option/parser/regexp'

module Acclaim
  class Command

    # Given an argument array and a list of commands, searches for them among
    # the elements of the array.
    class Parser

      # The argument array to be searched.
      attr_accessor :argv

      # The commands to search for.
      attr_accessor :commands

      # Initializes a new command parser, with the given argument array and set
      # of commands to search for.
      def initialize(argv, commands)
        self.argv = argv
        self.commands = commands
      end

      # Parses the argument array and returns one of the given commands, if one
      # is found, or +nil+ otherwise.
      def parse!
        find_command
      end

      private

      # Discards all elements in the argument array after and including the
      # argument separator, if one exists.
      #
      # Does not modify +argv+; returns a new array.
      def arguments_up_to_separator
        argv.take_while do |arg|
          arg !~ Option::Parser::Regexp::ARGUMENT_SEPARATOR
        end
      end

      # Searches for one of the given commands in the argument array, and
      # returns it. Removes the string that matched the command name from
      # +argv+. Returns +nil+ if no command was found.
      def find_command
        commands.find do |command|
          arguments_up_to_separator.include? command.line
        end.tap do |command|
          argv.delete command.line if command
        end
      end

    end

  end
end
