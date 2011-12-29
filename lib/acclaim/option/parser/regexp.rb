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
        SHORT_SWITCH = /\A-\w\Z/

        # Regular expression for a long option switch.
        #
        # Examples: <tt>--long; --no-feature; --with_underscore;
        # --_private-option; --1-1</tt>
        LONG_SWITCH = /\A--[\w\d]+(-[\w\d]+)*\Z/

        # Regular expression for multiple short options in a single "short"
        # switch.
        #
        # Examples: -xvf, -abc, -de_f
        MULTIPLE_SHORT_SWITCHES = /\A-\w{2,}\Z/

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
        SWITCH_PARAM_EQUALS = /\A--[\w\d]+(-[\w\d]+)*=(,*[\w\d]*)*\Z/

        # Regular expression for any kind of option switch.
        SWITCH = /(#{SHORT_SWITCH})|(#{LONG_SWITCH})|(#{MULTIPLE_SHORT_SWITCHES})|(#{SWITCH_PARAM_EQUALS})/

        # Regular expression for the string that separates options and their
        # parameters from arguments like filenames.
        #
        # Examples: <tt>--; ---</tt>
        ARGUMENT_SEPARATOR = /\A-{2,}\Z/

      end

    end
  end
end
