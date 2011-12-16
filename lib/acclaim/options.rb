module Acclaim

  # Represents a set of options.
  class Options

    def [](key)
      data[key]
    end

    def []=(key, value)
      data[key] = value
    end

    # Handles the following cases:
    #
    #   options.method = value
    #   options.method?
    #   options.method
    def method_missing(method, *args, &block)
      m = method.to_s
      case m
        when /=$/
          self[:"#{m.chop!}"] = args.first
        when /\?$/
          self[:"#{m.chop!}"] ? true : false
        else
          self[method]
      end
    end

    private

    # The option values
    def data
      @options ||= {}
    end


  end

end
