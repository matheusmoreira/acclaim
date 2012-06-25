module Acclaim
  module CoreExtensions

    # Acclaim extensions to the String class.
    #
    # @author Matheus Afonso Martins Moreira
    # @since 0.5.0
    module String
    end

  end
end

%w(

acclaim/core_extensions/string/ansi

).each { |file| require file }
