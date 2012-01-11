require 'acclaim/option/parser/regexp'
require 'ribbon'

module Acclaim
  class Option

    # Parses arrays of strings and returns an Options instance containing data.
    class Parser

      include Parser::Regexp

      # Errors raised by the parser.
      class Error < StandardError

        # Raises an Error with the following error message:
        #
        #   Wrong number of arguments (#{actual} for #{minimum})
        def self.raise_wrong_arg_number(actual, minimum, optional)
          raise self, "Wrong number of arguments (#{actual} for #{minimum})"
        end

        # Raises an Error with the following error message:
        #
        #   Missing required argument (arg)
        def self.raise_missing_arg(arg)
          raise self, "Missing required argument (#{arg})"
        end

        # Raises an error with the following error message:
        #
        #   Multiple instances of #{options.names.join ''} encountered
        def self.raise_multiple(option)
          names = option.names.join '|'
          raise self, "Multiple instances of [#{names}] encountered"
        end

      end

      attr_accessor :argv, :options

      # Initializes a new parser, with the given argument array and set of
      # options. If no option array is given, the argument array will be
      # preprocessed only.
      def initialize(argv, options = nil)
        self.argv = argv || []
        self.options = options || []
      end

      # Parses the meaning of the options given to this parser. If none were
      # given, the argument array will be preprocessed only. Any parsed options
      # and arguments will be removed from the argument array, so pass in a
      # duplicate if you need the original.
      #
      #   include Acclaim
      #
      #   args = %w(-F log.txt --verbose arg1 arg2)
      #   options = []
      #   options << Option.new(:file, '-F', arity: [1,0], required: true)
      #   options << Option.new(:verbose, '--verbose')
      #
      #   Option::Parser.new(args, options).parse!
      #   => {Ribbon file: "log.txt", verbose: true}
      #
      #   args
      #   => ["arg1", "arg2"]
      def parse!
        preprocess_argv!
        parse_values!
      end

      private

      # Preprocesses the argument array.
      def preprocess_argv!
        split_multiple_short_options!
        normalize_parameters!
        argv.compact!
      end

      # Splits multiple short options.
      #
      #   %w(-abcdef PARAM1 PARAM2) => %w(-a -b -c -d -e -f PARAM1 PARAM2)
      def split_multiple_short_options!
        argv.find_all { |arg| arg =~ MULTIPLE_SHORT_SWITCHES }.each do |multiples|
          multiples_index = argv.index multiples
          argv.delete multiples
          switches = multiples.sub!(/^-/, '').split(//).each { |letter| letter.prepend '-' }
          argv.insert multiples_index, *switches
        end
      end

      # Splits switches that are connected to a comma-separated parameter list.
      #
      #   %w(--switch=)              => %w(--switch)
      #   %w(--switch=PARAM1,PARAM2) => %w(--switch PARAM1 PARAM2)
      #   %w(--switch=PARAM1,)       => %w(--switch PARAM1)
      #   %w(--switch=,PARAM2)       =>   [ '--switch', '', 'PARAM2' ]
      def normalize_parameters!
        argv.find_all { |arg| arg =~ SWITCH_PARAM_EQUALS }.each do |switch|
          switch_index = argv.index switch
          argv.delete switch
          switch, params = switch.split /\=/
          params = (params or '').split /,/
          argv.insert switch_index, *[ switch, *params ]
        end
      end

      # Parses the options and their arguments, associating that information
      # with a Ribbon instance.
      def parse_values!
        ribbon = Ribbon.new
        options.each do |option|
          key = option.key
          ribbon[key] = option.default unless Ribbon[ribbon].has_key? key
          switches = argv.find_all { |switch| option =~ switch }
          Error.raise_missing_arg option.names.join('|') if option.required? and switches.empty?
          Error.raise_multiple option if option.on_multiple == :raise and switches.count > 1
          switches.each do |switch|
            if option.flag?
              found_boolean option, ribbon
              argv.delete_at argv.index(switch)
            else
              params = extract_parameters_of! option, switch
              found_params_for option, params, ribbon
            end
          end
        end
        ribbon
      end

      # Finds the +switch+ in #argv and scans the next +option.arity.total+
      # elements if +option.arity.bound?+ is +true+, or all parameters
      # otherwise. In either case, the algorithm will stop if it finds +nil+,
      # another switch or an argument separator among the parameters.
      #
      # Deletes the switch and every value that was extracted from #argv. Raises
      # an Error if the number of parameters found is less than
      # +option.arity.required+.
      def extract_parameters_of!(option, switch)
        arity = option.arity
        switch_index = argv.index switch
        len = if arity.bound?
          switch_index + arity.total
        else
          argv.length - 1
        end
        params = argv[switch_index + 1, len]
        values = []
        params.each do |param|
          case param
            when nil, SWITCH, ARGUMENT_SEPARATOR then break
            else
              break if arity.bound? and values.count >= arity.total
              values << param
          end
        end
        count = values.count
        Error.raise_wrong_arg_number count, *arity if count < arity.required
        argv.slice! switch_index..(switch_index + count)
        values
      end

      # If the option has an custom handler associated, it will be called with
      # the option values as the first argument and the array of parameters
      # found as the second argument. Otherwise, the value will be set to
      # <tt>params.first</tt>, if the option takes only one argument, or to
      # +params+ if it takes more.
      #
      # Appends +params+ to the current values of the option if the it specifies
      # so. In this case, the value of the option will always be an array.
      #
      # The parameters will be converted according to the option's type.
      def found_params_for(option, params = [], ribbon = Ribbon.new)
        params = option.convert_parameters *params
        if handler = option.handler then handler.call ribbon, params
        else
          key = option.key.to_sym
          value = option.arity.total == 1 ? params.first : params
          value = [*ribbon[key], *value] if option.on_multiple == :append
          ribbon[option.key.to_sym] = value unless params.empty?
        end
      end

      # If the option has an custom handler associated, it will be called with
      # only the option values as the first argument. Otherwise, the value will
      # be set to <tt>true</tt>.
      def found_boolean(option, ribbon = Ribbon.new)
        if handler = option.handler then handler.call ribbon
        else ribbon[option.key.to_sym] = true end
      end

    end
  end
end
