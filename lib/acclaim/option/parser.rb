require 'acclaim/option/parser/regexp'
require 'acclaim/option/values'

module Acclaim
  class Option

    # Parses arrays of strings and returns an Options instance containing data.
    class Parser

      include Parser::Regexp

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

      # Parses the meaning of the options given to this parser. If none were
      # given, the argument array will only be preprocessed. Any parsed options
      # and arguments will be removed from the argument array, so pass in a
      # duplicate if you need the original.
      def parse!
        preprocess_argv!
        parse_values! unless options.nil?
      end

      private

      # Argument array preprocessing.
      def preprocess_argv!
        split_multiple_short_options!
        normalize_parameters!
        # TODO: normalize parameter formats?
        # -sPARAM1[,PARAM2,PARAM3...] - possibly incompatible with split_multiple_short_options!
        argv.compact!
      end

      def split_multiple_short_options!
        argv.find_all { |arg| arg =~ MULTIPLE_SHORT_SWITCHES }.each do |multiples|
          multiples_index = argv.index multiples
          argv.delete multiples
          switches = multiples.sub!(/^-/, '').split(//).each { |letter| letter.prepend '-' }
          argv.insert multiples_index, *switches
        end
      end

      def normalize_parameters!
        argv.find_all { |arg| arg =~ SWITCH_PARAM_EQUALS }.each do |switch|
          switch_index = argv.index switch
          argv.delete switch
          switch, params = switch.split /\=/
          params = (params or '').split /,/
          argv.insert switch_index, *[ switch, *params ]
        end
      end

      def parse_values!
        Values.new.tap do |options_instance|
          options.each do |option|
            key = option.key
            options_instance[key] = option.default unless options_instance[key]
            switches = argv.find_all { |switch| option =~ switch }
            if switches.any?
              if option.flag?
                set_option_value option, options_instance
              else
                switches.each do |switch|
                  params = extract_parameters_of! option, switch
                  argv.delete switch
                  set_option_value option, options_instance, params
                end
              end
            else
              Error.raise_missing_arg(option.names.join ' | ') if option.required?
            end
          end
        end
      end

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
        values.each { |value| argv.delete value }
      end

      def set_option_value(option, values, params = [])
        if handler = option.handler
          if option.flag? then handler.call values
          else handler.call values, params end
        else
          key = option.key.to_sym
          if option.flag? then values[key] = true
          else
            value = option.arity.total == 1 ? params.first : params
            values[key] = value unless params.empty?
          end
        end
      end

    end
  end
end
