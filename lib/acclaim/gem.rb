require 'jewel'

module Acclaim

  # Acclaim gem information and metadata.
  #
  # @author Matheus Afonso Martins Moreira
  # @since 0.4.0
  class Gem < Jewel::Gem

    root '../..'

    specification ::Gem::Specification.load root.join('acclaim.gemspec').to_s

  end

end
