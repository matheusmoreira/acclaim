require 'acclaim/ansi'

module Acclaim
  module CoreExtensions
    module String

      # Object-oriented ANSI escape code API.
      #
      # @see Acclaim::ANSI Acclaim::ANSI
      # @author Matheus Afonso Martins Moreira
      # @since 0.5.0
      module ANSI

        # Applies foreground color to this string.
        #
        # @param [Symbol] color the name of the color that will be applied
        # @return [String] new string with the color applied
        # @see #background
        # @see Acclaim::ANSI.supported_colors
        def foreground(color)
          Acclaim::ANSI.foreground_color self, color
        end

        # Applies background color to this string.
        #
        # @param [Symbol] color the name of the color that will be applied
        # @return [String] new string with the color applied
        # @see #foreground
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

        colors, effects = Acclaim::ANSI.supported_colors, Acclaim::ANSI.supported_effects

        colors.each do |color|
          define_method color do
            foreground color
          end
        end

        effects.each do |effect|
          define_method effect do
            effects effect
          end
        end

        colors.product(colors).each do |(fg, bg)|
          define_method :"#{fg}_on_#{bg}" do
            foreground(fg).background bg
          end
        end

      end

      ::String.send :include, ANSI

    end
  end
end
