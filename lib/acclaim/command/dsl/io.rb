require 'acclaim/io'

module Acclaim
  class Command
    module DSL

      # High-level input/output methods.
      #
      # @author Matheus Afonso Martins Moreira
      # @since 0.6.0
      module IO

        Acclaim::IO.instance_methods(false).each do |method_name|
          define_method method_name do |*arguments, &block|
            io.send method_name, *arguments, &block
          end
        end

      end

    end
  end
end
