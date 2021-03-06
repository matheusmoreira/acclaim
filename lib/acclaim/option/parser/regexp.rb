module Acclaim
  class Option
    class Parser

      # Contains all regular expressions used by the parser.
      module Regexp

        # Regular expression for a short option switch.
        #
        # Examples: <tt>-s; -_</tt>
        #
        # <tt>'-mult'</tt> should match MULTIPLE_SHORT_SWITCHES, and will be
        # split into <tt>%w(-m -u -l -t)</tt>, which in turn should match this
        # regular expression.
        #
        # \w is not used because it matches digits.
        SHORT_SWITCH = /\A-[a-zA-Z_]\Z/.freeze

        # Regular expression for a long option switch.
        #
        # Examples: <tt>--long; --no-feature; --with_underscore;
        # --_private-option; --1-1</tt>
        LONG_SWITCH = /\A--\w+(-\w+)*\Z/.freeze

        # Regular expression for multiple short options in a single "short"
        # switch.
        #
        # Examples: <tt>-xvf; -abc; -de_f</tt>
        #
        # \w is not used because it matches digits.
        MULTIPLE_SHORT_SWITCHES = /\A-[a-zA-Z_]{2,}\Z/.freeze

        # Regular expression for a long switch connected to its parameters with
        # an equal sign. Multiple parameters are be separated by commas.
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
        SWITCH_PARAM_EQUALS = /\A--\w+(-\w+)*=(,*\w*)*\Z/.freeze

        # Regular expression for any kind of option switch.
        SWITCH = ::Regexp.union(SHORT_SWITCH, LONG_SWITCH).freeze

        # Regular expression for the string that separates options and their
        # parameters from arguments like filenames.
        #
        # Examples: <tt>--; ---</tt>
        ARGUMENT_SEPARATOR = /\A-{2,}\Z/.freeze

      end

    end
  end
end
