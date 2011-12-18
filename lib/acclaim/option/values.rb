module Acclaim
  class Option

    # Represents a set of option values.
    class Values

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
      #   options.method?         =>  options[method] ? true : false
      #   options.method          =>  options[method]
      def method_missing(method, *args, &block)
        m = method.to_s.chop!.to_sym
        case method
          when /=$/
            self[m] = args.first
          when /\?$/
            self[m] ? true : false
          else
            self[method]
        end
      end

      protected

      # The option values
      def data
        @options ||= {}
      end

    end

  end
end
