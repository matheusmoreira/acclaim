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

        # Adds version subcommand and options to this command.
        #
        # @see Acclaim::Command::Help.create
        def version(string, *arguments, &block)
          Version.create root, string, arguments.extract_ribbon!, &block
        end

      end

    end
  end
end
