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
          help_data :description, *arguments, &block
        end

        # This command's usage notes.
        #
        # @overload note
        #   Returns this command's usage notes.
        #
        #   @return [String] this command's usage notes
        #
        # @overload note(string)
        #   Stores the given string as this command's usage notes.
        #
        #   @param [#to_s] string the notes
        #   @return [String] the given notes
        #
        # @overload note(&block)
        #   Calls the given block to determine the usage notes when needed.
        #
        #   @param [#call] block the block to call
        #   @return [Proc] the given block
        #   @yieldreturn [String] the usage notes
        def note(*arguments, &block)
          help_data :note, *arguments, &block
        end

        alias notes note
        alias notice note

        # This command's arbitrary, noncontextual help text.
        #
        # @overload text
        #   Returns this command's help text.
        #
        #   @return [String] the help text
        #
        # @overload text(string)
        #   Stores the given string as this command's help text.
        #
        #   @param [#to_s] string the help text
        #   @return [String] the given text
        #
        # @overload text(&block)
        #   When needed, the block will be called to determine the help text.
        #
        #   @param [#call] block the block to call
        #   @return [Proc] the given block
        #   @yieldreturn [String] the help text
        def text(*arguments, &block)
          help_data :text, *arguments, &block
        end

        private

        # Stores data such as description, usage notes and examples.
        #
        # @param [#to_sym] key the key the data is associated with
        #
        # @overload help_data(key)
        #   Returns the data associated with the given key.
        #
        #   @return [String] the data
        #
        # @overload help_data(key, data)
        #   Associates the data with the given key.
        #
        #   @param [#to_s] data the data to store
        #   @return [String] the data
        #
        # @overload help_data(key, &block)
        #   When needed, the block will be called to obtain the data.
        #
        #   @param [#call] block the block to call
        #   @return [Proc] the given block
        #   @yieldreturn [String] the data
        def help_data(key, *arguments, &block)
          @help_data ||= Ribbon.new

          if block.respond_to? :call then @help_data[key] = block
          elsif arguments.any? then @help_data[key] = arguments.first.to_s
          else
            data = @help_data[key]

            if data.nil? then data
            else
              if data.respond_to? :call then data.call else data end.to_s
            end
          end
        end

      end
    end
  end
end
