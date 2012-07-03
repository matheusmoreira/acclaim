require 'erb'
require 'ribbon/core_extensions/array'

module Acclaim
  class Command
    module Help

      # Manages help templates.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.0.5
      module Template
      end

      class << Template

        # Returns the path to the directory where templates are stored.
        #
        # @return [String] absolute path to the templates directory
        # @since 0.6.0
        def directory
          Acclaim::Gem.root.templates.help('template').to_s
        end

        alias folder directory

        # Loads the contents of a template file from the template #folder.
        def load(template_file)
          File.read File.join(folder, template_file)
        end

        # Creates a new ERB instance with the contents of +template+.
        def create_from(template_file)
          ERB.new load(template_file), nil, '%<>'
        end

        # Computes the result of the template +file+ using the +command+'s
        # binding.
        #
        # @param [Acclaim::Command::DSL] command the command to display help for
        # @param [Hash, Ribbon, Ribbon::Wrapper] template_options template
        #   configuration options
        # @option template_options [true, false] :include_root (false) whether
        #   to include the root command in command invocation lines
        def for(command, template_options = {})
          template_options = Ribbon.wrap options
          template = create_from template_options.file? 'command.erb'
          command_binding = command.instance_eval { binding }
          # Since blocks are closures, the binding has access to the
          # template_options ribbon:
          #
          # p command_binding.eval 'template_options'
          #  => {}
          template.result command_binding
        end

      end

    end
  end
end
