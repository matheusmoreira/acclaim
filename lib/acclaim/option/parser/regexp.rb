module Acclaim
  class Option
    class Parser

      # Contains all regular expressions used by the parser.
      module Regexp

        # Regular expression for a short option switch.
        #
        # Matches strings that begin with a single dash and contain only word
        # characters or digits until the end of the string.
        #
        # Examples: <tt>-s; -mult; -5; -_</tt>
        #
        # <tt>'-mult'</tt> will be split into <tt>%w(-m -u -l -t)</tt>.
        SHORT_SWITCH = /\A-[\w\d]+\Z/

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

        # Regular expression for any kind of option switch.
        #
        # Matches either a SHORT_SWITCH or a LONG_SWITCH. See their descriptions
        # for details.
        SWITCH = /(#{SHORT_SWITCH})|(#{LONG_SWITCH})/

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
        # either nothing or zero or one commands plus one or more word character
        # or digit.
        #
        # Examples:
        # <tt>--switch=PARAM; --files=f1,f2,f3; --weird=,PARAM2; --none=</tt>
        #
        # The reason something like <tt>'--none='</tt> is allowed is because it
        # will become <tt>['--none', '']</tt> when it is split up.
        # <tt>'--weird=,PARAM2'</tt> will become
        # <tt>['--weird', '', 'PARAM2']</tt> when it is split up. What to make
        # of those isn't a decision for a preprocessor.
        PARAM_EQUALS_SWITCH = /\A--[\w\d]+(-?[\w\d]+)*=(,{0,1}[\w\d]+)*\Z/

        # Regular expression for the string that separates options and their
        # parameters from arguments like filenames.
        #
        # Matches strings made up of 2 or more dashes.
        ARGUMENT_SEPARATOR = /\A-{2,}\Z/

      end

    end
  end
end
