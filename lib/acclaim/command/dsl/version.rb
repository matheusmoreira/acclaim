%w(

acclaim/command/version

ribbon/core_extensions/array

).each { |file| require file }

module Acclaim
  class Command
    module DSL

      # Domain-specific language methods related to Acclaim's version system.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.6.0
      module Help

        # Adds version subcommand and options to this command.
        #
        # @see Acclaim::Command::Help.create
        def version(string, *arguments, &block)
          Command::Version.create root, string, arguments.extract_ribbon!, &block
        end

      end
    end
  end
end
