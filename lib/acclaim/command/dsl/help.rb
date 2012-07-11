%w(

acclaim/command/help

ribbon/core_extensions/array

).each { |file| require file }

module Acclaim
  class Command
    module DSL

      # Domain-specific language methods related to Acclaim's help system.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.6.0
      module Help

        # Adds help subcommand and options to the root command.
        #
        # @see Acclaim::Command::Help.create
        def help(*arguments, &block)
          Command::Help.create root, arguments.extract_ribbon!, &block
        end

      end
    end
  end
end
