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

        # This command's description.
        #
        # @overload description
        #   Returns this command's description.
        #
        #   @return [String] this command's description
        #
        # @overload description(string)
        #   Stores the given string as this command's description.
        #
        #   @param [#to_s] string the description
        #   @return [String] the given description
        #
        # @overload description(&block)
        #   Calls the given block to determine the description when needed.
        #
        #   @param [#call] block the block to call
        #   @return [Proc] the given block
        #   @yieldreturn [String] the description
        def description(*arguments, &block)
          if block.respond_to? :call then @description = block
          elsif arguments.any? then @description = arguments.first.to_s
          elsif @description.respond_to? :call then @description.call.to_s
          else @description.to_s end
        end

      end
    end
  end
end
