require 'erb'

module Acclaim
  class Command
    module Help

      # Manages help templates.
      module Template

        def self.load(template)
          filename = File.join File.dirname(__FILE__), 'template', template
          ERB.new File.read(filename), nil, '%<>'
        end

        def self.for(command, file = 'command.erb')
          template = self.load file
          b = command.instance_eval { binding }
          template.result b
        end

      end

    end
  end
end
