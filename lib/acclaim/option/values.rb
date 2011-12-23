module Acclaim
  class Option

    # Represents a set of option values.
    class Values < BasicObject

      # Initializes a values instance, merging the values of the given hash with
      # the internal data.
      def initialize(hash = {})
        self.data.merge! hash
      end

      # Gets a value by key.
      def [](key)
        data[key]
      end

      # Sets a value by key.
      def []=(key, value)
        data[key] = value
      end

      # Merge these values with the others.
      def merge!(other, &block)
        data.merge! other.data, &block
      end

      # Handles the following cases:
      #
      #   options.method = value  =>  options[method] = value
      #   options.method! value   =>  options[method] = value; options
      #   options.method?         =>  options[method] ? true : false
      #   options.method          =>  options[method]
      def method_missing(method, *args, &block)
        m = method.to_s.chop!.to_sym
        case method.to_s[-1]
          when '=', '!'
            self[m] = args.first
          when '?'
            self[m] ? true : false
          else
            self[method] = if data.has_key? method
              Values.convert self[method]
            else
              Values.new
            end
        end
      end

      # Returns the class name followed by key => value pairs.
      def to_s
        values = data.map { |k, v| "#{k.inspect} => #{v.inspect}"  }
        "#{values.any? ? values.join(', ') : 'none'}"
      end

      # Returns the output of #to_s enclosed in angle brackets.
      def inspect
        "<#{to_s}>"
      end

      # If the value is a hash, converts it to a Values object. If it is an
      # array, attempts to convert any hashes which may be inside.
      def self.convert(value)
        case value
          when Hash then Values.new value
          when Array then value.map { |element| convert element }
          else value
        end
      end

      protected

      # The option values.
      def data
        @options ||= {}
      end

    end

  end
end
