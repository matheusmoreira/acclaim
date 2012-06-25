require 'acclaim/ansi'

module Acclaim
  module CoreExtensions
    module String

      # Object-oriented ANSI escape code API.
      #
      # @see Acclaim::ANSI
      # @author Matheus Afonso Martins Moreira
      # @since 0.5.0
      module ANSI

        # Applies foreground color to this string.
        #
        # @param [Symbol] color the name of the color that will be applied
        # @return [String] new string with the color applied
        # @see background
        # @see Acclaim::ANSI.supported_colors
        def foreground(color)
          Acclaim::ANSI.foreground_color self, color
        end

        # Applies background color to this string.
        #
        # @param [Symbol] color the name of the color that will be applied
        # @return [String] new string with the color applied
        # @see foreground
        # @see Acclaim::ANSI.supported_colors
        def background(color)
          Acclaim::ANSI.background_color self, color
        end

        # Applies text effects to this string.
        #
        # @param [Array<Symbol>] effects the text effects to apply
        # @return [String] new string with the text effects applied
        # @see Acclaim::ANSI.supported_effects
        def effects(*effects)
          Acclaim::ANSI.effects self, *effects
        end

      end

      ::String.send :include, ANSI

    end
  end
end
