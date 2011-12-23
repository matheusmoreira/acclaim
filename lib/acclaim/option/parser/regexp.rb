module Acclaim
  class Option
    class Parser

      # Contains all regular expressions used by the parser.
      module Regexp

        # Regular expression for a short option switch.
        #
        # Matches strings that begin with a single dash and contains only one
        # word character or digit before the end of the string.
        #
        # Examples: <tt>-s; -5; -_</tt>
        #
        # <tt>'-mult'</tt> will be split into <tt>%w(-m -u -l -t)</tt>.
        SHORT_SWITCH = /\A-[\w\d]\Z/

        # Regular expression for a long option switch.
        #
        # Matches strings that begin with a double dash, contain one or more
        # word character or digit, and can be followed by either nothing or a
        # single dash. The latter must be followed by one or more word character
        # or digit.
        #
        # Examples: <tt>--long; --no-feature; --with_underscore;
        # --_private-option; --1-1</tt>
        LONG_SWITCH = /\A--[\w\d]+(-[\w\d]+)*\Z/

        # Regular expression for multiple short options in a single "short"
        # switch.
        #
        # Matches strings that begin with a single dash and are followed by 2 or
        # more word characters, among which is the underscore but not the dash
        # character.
        #
        # Examples: -xvf, -abc, -de_f
        MULTIPLE_SHORT_SWITCHES = /\A-\w{2,}\Z/

        # Regular expression for a long switch connected to its parameters with
        # an equal sign. Multiple parameters are be separated by commas.
        #
        # Matches strings that begin with a double dash, are followed by one or
        # more word character or digit and may be followed by one dash and one
        # or more word character or digit.
        #
        # After that, there must be an equals sign, which must be followed by
        # either nothing, any number of commmas or any number of word characters
        # or digits.
        #
        # Examples:
        # <tt>
        # --switch=PARAM; --files=f1,f2,f3; --weird=,PARAM2; --empty=,,; --none=
        # </tt>
        #
        # The reason something like <tt>'--none='</tt> is allowed is because it
        # will become <tt>['--none']</tt> when it is split up.
        # <tt>'--empty=,,'</tt> will become <tt>['--empty']</tt>
        # <tt>'--weird=,PARAM2'</tt> will become
        # <tt>['--weird', '', 'PARAM2']</tt> when it is split up. What to make
        # of those isn't a decision for a preprocessor.
        SWITCH_PARAM_EQUALS = /\A--[\w\d]+(-?[\w\d]+)*=(,*[\w\d]*)*\Z/

        # Regular expression for any kind of option switch.
        #
        # Matches anything that matches any of the other switch regular
        # expressions.
        SWITCH = /(#{SHORT_SWITCH})|(#{LONG_SWITCH})|(#{MULTIPLE_SHORT_SWITCHES})|(#{SWITCH_PARAM_EQUALS})/

        # Regular expression for the string that separates options and their
        # parameters from arguments like filenames.
        #
        # Matches strings made up of 2 or more dashes.
        ARGUMENT_SEPARATOR = /\A-{2,}\Z/

      end

    end
  end
end
