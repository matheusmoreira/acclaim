%w(

acclaim/command/help
acclaim/command/version

ribbon/core_extensions/array

).each { |file| require file }

module Acclaim
  class Command
    module DSL

      # Methods that only work with root commands.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.4.0
      module Root

        # Adds help subcommand and options to this command.
        #
        # @see Acclaim::Command::Help.create
        def help(*arguments, &block)
          Help.create root, *arguments, &block
        end

        # Adds version subcommand and options to this command.
        #
        # @see Acclaim::Command::Help.create
        def version(*arguments, &block)
          Version.create root, *arguments, &block
        end

      end

    end
  end
end
