require 'acclaim/options'

module Acclaim
  class Option

    # Parses arrays of strings and returns an Options instance containing data.
    class Parser

      # Regular expression for any kind of option switch.
      #
      # Matches strings that begin with 1 or 2 dashes, are followed by at least
      # one word character or number, and may be followed by any other word
      # character, number or dash.
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

      # Regular expression for the string that separates options and their
      # parameters from arguments like filenames.
      #
      # Matches strings made up of 2 or more dashes.
      ARGUMENT_SEPARATOR = /^-{2,}$/

      class Error < StandardError

        def self.raise_wrong_arg_number(actual, minimum, optional)
          raise self, "Wrong number of arguments (#{actual} for #{minimum})"
        end

        def self.raise_missing_arg(arg)
          raise self, "Missing required argument (#{arg})"
        end

      end

      attr_accessor :argv, :options

      # Initializes a new parser, with the given argument array and set of
      # options. If no option array is given, the argument array will be
      # preprocessed only.
      def initialize(argv, options = nil)
        self.argv = argv
        self.options = options
      end

      def parse!
        preprocess_argv!
        instance = build_options_instance! unless options.nil?
      end

      private

      # Argument array preprocessing.
      def preprocess_argv!
        split_multiple_short_options!
        # TODO: normalize parameter formats?
        # --switch=PARAM1[,PARAM2,PARAM3] - split on =, then split on comma,
        #                                   then reinsert them into argv
        # -sPARAM1[,PARAM2,PARAM3...] - possibly incompatible with split_multiple_short_options!
        argv.compact!
      end

      def split_multiple_short_options!
        argv.find_all { |arg| arg =~ MULTIPLE_SHORT_SWITCHES }.each do |multiples|
          multiples_index = argv.index multiples
          argv.delete multiples
          letters = multiples.sub!(/^-/, '').split(//)
          letters.each { |letter| letter.prepend '-' }.tap do |options|
            options.each_index do |option_index|
              argv.insert multiples_index + option_index, options[option_index]
            end
          end
        end
      end

      def build_options_instance!
        Options.new.tap do |options_instance|
          options.each do |option|
            key = option.key.to_sym
            options_instance[key] = option.default
            args = argv.find_all { |arg| option =~ arg }
            if args.any?
              if option.flag?
                options_instance[key] = true
              else
                arity = option.arity
                args.each do |arg|
                  arg_index = argv.index arg
                  len = if arity.bound?
                    arg_index + arity.total
                  else
                    argv.length - 1
                  end
                  params = argv[arg_index + 1, len]
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
                  Error.raise_wrong_arg_number count, *option.arity if count < arity.required
                  options_instance[key] = if arity.only? 1
                    values.first
                  else
                    values
                  end
                  values.each { |value| argv.delete value }
                end
              end
              args.each { |arg| argv.delete arg }
            else
              Error.raise_missing_arg(option.names.join ' | ') if option.required?
            end
          end
        end
      end

    end
  end
end
