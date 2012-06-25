module Acclaim

  # Acclaim extensions to the Ruby standard library.
  #
  # @author Matheus Afonso Martins Moreira
  # @since 0.5.0
  module CoreExtensions
  end

end

%w(

acclaim/core_extensions/string

).each { |file| require file }
