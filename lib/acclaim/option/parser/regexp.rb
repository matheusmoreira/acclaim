module Acclaim
  class Option
    class Parser

      # Contains all regular expressions used by the parser.
      module Regexp

        # Regular expression for any kind of option switch.
        #
        # Matches strings that begin with 1 or 2 dashes, are followed by at
        # least one word character or number, and may be followed by any other
        # word character, number or dash.
        #
        # Examples: -s, --long, -multiple, -1, --no-feature, --with_underscore,
        #           --_private_option, etc.
        SWITCH = /^-{1,2}[\w\d]+[\w\d-]*$/

        # Regular expression for multiple short options in a single "short"
        # switch.
        #
        # Matches strings that begin with a single dash and are followed by 2 or
        # more word characters, among which is the underscore but not the dash
        # character.
        #
        # Examples: -xvf, -abc, -de_f
        MULTIPLE_SHORT_SWITCHES = /^-\w{2,}$/

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
        PARAM_EQUALS_SWITCH = /^--[\w\d]+(-?[\w\d]+)*=(,{0,1}[\w\d]+)*$/

        # Regular expression for the string that separates options and their
        # parameters from arguments like filenames.
        #
        # Matches strings made up of 2 or more dashes.
        ARGUMENT_SEPARATOR = /^-{2,}$/

      end

    end
  end
end
