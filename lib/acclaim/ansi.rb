require 'ribbon'

module Acclaim

  # ANSI escape codes for colors and effects.
  #
  # @see http://en.wikipedia.org/wiki/ANSI_escape_code ANSI escape code
  # @author Matheus Afonso Martins Moreira
  # @since 0.5.0
  module ANSI
  end

  class << ANSI

    # Extends the String class with an object-oriented ANSI escape code API.
    #
    # @see Acclaim::CoreExtensions::String::ANSI
    def extend_string!
      require 'acclaim/core_extensions/string/ansi'
    end

    # Colors from the standard color pallete.
    #
    # @return [Array<Symbol>] available colors
    # @see foreground_color
    # @see background_color
    # @see supported_effects
    def supported_colors
      colors.keys
    end

    alias available_colors supported_colors

    # Text effects that can be applied.
    #
    # @return [Array<Symbol>] available text effects
    # @see effects
    # @see supported_colors
    def supported_effects
      text_effects.keys
    end

    alias available_effects supported_effects

    # Applies foreground color to the string.
    #
    # @param [String, #to_s] string the string the color will be applied to
    # @param [Symbol] color the name of the color that will be applied
    # @return [String] new string with the color applied
    # @see background_color
    # @see supported_colors
    def foreground_color(string, color)
      apply_color_to string, color, foreground_offset
    end

    alias apply foreground_color

    # Applies background color to the string.
    #
    # @param [String, #to_s] string the string the color will be applied to
    # @param [Symbol] color the name of the color that will be applied
    # @return [String] new string with the color applied
    # @see foreground_color
    # @see supported_colors
    def background_color(string, color)
      apply_color_to string, color, background_offset
    end

    # Applies text effects to the given string.
    #
    # @param [String, #to_s] string the string the effects will be applied to
    # @param [Array<Symbol>] effects the text effects to apply
    # @return [String] new string with the text effects applied
    # @see supported_effects
    def effects(string, *effects)
      apply_escape_codes_to string do
        effects.select do |effect|
          text_effects.has_key? effect
        end.map do |effect|
          text_effects[effect]
        end
      end
    end

    private

    # Computes the color escape code and applies it to the string.
    #
    # @param [String, #to_s] string the string the color will be applied to
    # @param [Symbol] color the name of the color that will be applied
    # @param [Integer] offset background or foreground color code offset
    # @return [String] new string with the color applied
    def apply_color_to(string, color, offset)
      apply_escape_code_to string do
        offset + colors[color] if colors.has_key? color
      end
    end

    # Applies the escape codes returned by the block to the given string.
    #
    # @note A reset escape code will be appended to the string if it does not
    #   end with one.
    #
    # @param [String, #to_s] string the string the code will be applied to
    # @yieldreturn [Integer, Array<Integer>] escape code(s) to apply
    # @return [String] new string with the escape codes applied
    def apply_escape_codes_to(string)
      string.to_s.dup.tap do |string|
        [*yield].map(&:to_i).each do |escape_code|
          string.prepend select_graphic_rendition escape_code
        end

        code = reset
        string.concat code unless self =~ /#{Regexp.escape code}\z/ix
      end
    end

    alias apply_escape_code_to apply_escape_codes_to

    # Escape code that resets all SGR settings.
    #
    # @return [String] reset escape code
    def reset
      select_graphic_rendition
    end

    # Creates a Select Graphic Rendition (SGR) escape code.
    #
    # @param [Integer] parameter the SGR parameter
    # @return [String] escape code string
    def select_graphic_rendition(parameter = 0)
      "\e[#{parameter}m"
    end

    alias sgr select_graphic_rendition

    # Foreground color SGR parameter offset.
    #
    # @return [Integer] the offset where background colors start
    # @see background_offset
    # @see colors
    def foreground_offset
      30
    end

    # Background color SGR parameter offset.
    #
    # @return [Integer] the offset where foreground colors start
    # @see foreground_offset
    # @see colors
    def background_offset
      40
    end

    # Color names mapped to their escape codes.
    #
    # @note These values should be used with an appropriate offset.
    #
    # @return [Hash] colors associated with their escape codes
    # @see foreground_offset
    # @see background_offset
    def colors
      @colors ||= Ribbon.wrap do
        black 0
        red 1
        green 2
        yellow 3
        blue 4
        magenta 5
        cyan 6
        white 7
        ribbon.default 9
      end.to_hash
    end

    # Text effects mapped to their escape codes.
    #
    # @return [Hash] effects associated with their escape codes
    def text_effects
      @text_effects ||= Ribbon.wrap do
        bright bold 1
        faint 2
        italic 3
        underline 4
        blink 5
        negative inverse reverse 7
        conceal hide 8
        strikethrough strikeout crossed_out 9
      end.to_hash
    end

  end

end
