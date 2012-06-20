%w(

acclaim/command/help
acclaim/command/version

).each { |file| require file }

module Acclaim
  class Command
    module DSL

      # Methods available to root commands only.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.4.0
      module Root

        # Adds help subcommand and options to this command.
        #
        # @see Acclaim::Command::Help.create
        def help(*arguments, &block)
          Help.create self, *arguments, &block
        end

        # Adds version subcommand and options to this command.
        #
        # @see Acclaim::Command::Help.create
        def version(*arguments, &block)
          Version.create self, *arguments, &block
        end

      end

    end
  end
end
