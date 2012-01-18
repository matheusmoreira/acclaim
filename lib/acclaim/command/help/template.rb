require 'erb'

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

          # Loads an ERB template file from the
          # +lib/acclaim/command/help/template+ folder and instantiates a new
          # ERB instance with its contents.
          def load(template)
            filename = File.join File.dirname(__FILE__), 'template', template
            ERB.new File.read(filename), nil, '%<>'
          end

          # Computes the result of the template +file+ using the +command+'s
          # binding.
          def for(command, file = 'command.erb')
            template = self.load file
            b = command.instance_eval { binding }
            template.result b
          end

        end

      end

    end
  end
end
