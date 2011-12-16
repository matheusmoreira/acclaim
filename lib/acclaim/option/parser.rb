require 'acclaim/options'

module Acclaim
  class Option

    # Parses arrays of strings and returns an Options instance containing data.
    class Parser

      class Error < StandardError; end

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

      # Argument array preprocessing. Does not touch
      def preprocess_argv!
        split_multiple_short_options!
        # TODO: normalize parameter formats?
        # --switch=PARAM1[,PARAM2,PARAM3] - split on =, then split on comma,
        #                                   then reinsert them into argv
        # -sPARAM1[,PARAM2,PARAM3...] - possibly incompatible with split_multiple_short_options!
        argv.compact!
      end

      def split_multiple_short_options!
        argv.find_all { |arg| arg =~ /^-\w{2,}/ }.each do |multiples|
          multiples_index = argv.index multiples
          argv.delete multiples
          options, *parameters = multiples.split /\s+/
          separated_options = options.sub!(/^-/, '').split(//).map! { |option| option.prepend '-' }
          separated_options.each_index do |option_index|
            argv.insert multiples_index + option_index, separated_options[option_index]
          end
          last_option_index = argv.index separated_options.last
          parameters.each_index do |parameter_index|
            argv.insert last_option_index + paramter_index + 1,
                        parameters[parameter_index]
          end
        end
      end

      def build_options_instance!
        Options.new.tap do |options_instance|
          options.each do |option|
            key = option.name.to_s.to_sym
            options_instance[key] = option.default
            args = argv.find_all { |arg| option =~ arg }
            if args.any?
              if option.flag?
                options_instance[key] = true
              else
                minimum, optional = option.arity
                args.each do |arg|
                  arg_index = argv.index arg
                  len = if optional >= 0
                    arg_index + minimum + optional
                  else
                    argv.length - 1
                  end
                  params = argv[arg_index + 1, len]
                  values = []
                  params.each do |param|
                    break if param.nil? or param =~ /^-{1,2}/ or param =~ /^-{2,}$/
                    values << param
                  end
                  count = values.count
                  if count < minimum
                    raise Error, "Wrong number of arguments (%d for %d)" % [count, minimum]
                  end
                  options_instance[key] = if minimum == 1 and optional.zero?
                    values.first
                  else
                    values
                  end
                  values.each { |value| argv.delete value }
                end
              end
              args.each { |arg| argv.delete arg }
            end
          end
        end
      end

    end
  end
end
