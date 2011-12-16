require 'acclaim/option'
require 'acclaim/option/parser'

module Acclaim

  # A command is a single word whose meaning the program understands. It calls
  # upon a function of the program, which may be fine-tuned with options and
  # given arguments.
  #
  #   app --global-option do --option
  #
  # A subcommand benefits from its parent's option processing.
  #
  #   app do something --option --option-for-something
  #
  # A command can be instantiated in the following form:
  #
  #   cmd = Command.new :foo do
  #     opt :verbose, short: '-v', long: '--verbose',
  #                   description: 'Run verbosely', default: false
  #   end
  #
  # TODO: make these class methods instead of instance methods, with one class
  #       per command
  class Command

    attr_accessor :name, :action

    # Initializes a command with a name and evalutes the block if one is given.
    def initialize(name, &block)
      self.name = name.to_s
      instance_eval &block if block
    end

    # The options this command can take.
    def options
      @options ||= []
    end

    def option(name, args)
      args.merge!(:name => name) { |key, old, new| new }
      options << Option.new(args)
    end

    alias :opt :option

    # Executes the command with the given options and arguments.
    def execute(options, *args)
      action.call options, *args
    end

    def parse_options!(*args)
    end

    alias :call :execute

    # The commands that may be given to this command.
    def subcommands
      @subcommands ||= []
    end

    def subcommand(*args, &block)
      subcommands << Command.new(*args, &block)
    end

  end

end
