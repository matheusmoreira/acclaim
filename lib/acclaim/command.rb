%w(

acclaim/command/dsl
acclaim/command/parser
acclaim/option
acclaim/option/parser
acclaim/option/parser/regexp

ribbon
ribbon/core_extensions/object

).each { |file| require file }

module Acclaim

  # A command is a single word whose meaning the program understands. It calls
  # upon a function of the program, which may be fine-tuned with options and
  # given arguments.
  #
  #   app --global-option do --option
  #
  # A subcommand benefits from its parent's option processing.
  #
  #   app --global-option do something --option-for-do --option-for-something
  #
  # A command can be created in the following form:
  #
  #   class App::Command < Acclaim::Command
  #     option :verbose, '-v', '--verbose', 'Run verbosely'
  #   end
  #
  # A subcommand can be created by inheriting from another command:
  #
  #   class App::Command::Do < App::Command
  #     opt :what, '-W', '--what', 'What to do', arity: [1, 0], required: true
  #     when_called do |options, arguments|
  #       puts "Verbose? #{options.verbose? ? :yes : :no}"
  #       puts "Doing #{options.what} with #{arguments.join ' and ')}!"
  #     end
  #   end
  #
  # Then, in your application's binary, you may simply write:
  #
  #   App::Command.run *ARGV
  #
  # See it in action:
  #
  #   $ app --verbose do --what testing acclaim safeguard
  #   Verbose? yes
  #   Doing testing with acclaim and safeguard!
  class Command

    extend DSL

  end

  class << Command

    # Add the class methods to the subclass and add it to this command's list of
    # subcommands.
    #
    # @param [Class] subcommand the class that inherited from this command
    def inherited(subcommand)
      subcommand.extend Acclaim::Command::DSL::Root if subcommand.root?
      subcommands << subcommand if respond_to? :subcommands
    end

  end

end
