require 'erb'
require 'ribbon/core_ext/array'

module Acclaim
  class Command
    module Help

      # Manages help templates.
      module Template

        # The class methods.
        class << self

          # Returns the +template+ folder relative to this directory.
          def folder
            File.join File.dirname(__FILE__), 'template'
          end

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
          def for(*args)
            template_options, command = args.extract_ribbon!, args.shift
            template = create_from template_options.file?('command.erb')
            b = command.instance_eval { binding }
            # Since blocks are closures, the binding has access to the
            # template_options ribbon:
            #
            # p b.eval 'template_options'
            #  => {}
            template.result b
          end

        end

      end

    end
  end
end
