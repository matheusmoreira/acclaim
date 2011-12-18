require 'acclaim/option/arity'
require 'acclaim/option/parser/regexp'

module Acclaim

  # Represents a command-line option.
  class Option

    attr_accessor :key, :names, :description, :type, :default

    def initialize(key, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      self.key         = key
      self.names       = args.find_all { |arg| arg =~ Parser::Regexp::SWITCH }
      self.description = args.find     { |arg| arg !~ Parser::Regexp::SWITCH }
      self.type        = args.find     { |arg| arg.is_a? Class }
      self.arity       = options[:arity]
      self.default     = options[:default]
      self.required    = options[:required]
      yield self if block_given?
    end

    def =~(str)
      names.include? str.strip
    end

    def arity
      @arity ||= Arity.new
    end

    def arity=(arity_or_array)
      @arity = if arity.nil? or arity_or_array.is_a? Arity
        arity_or_array
      else
        Arity.new *arity_or_array
      end
    end

    def required?
      @required
    end

    def required=(value)
      @required = value
    end

    def require
      self.required = true
    end

    def flag?
      not arity or arity == [0, 0]
    end

    alias :bool?    :flag?
    alias :boolean? :flag?
    alias :switch?  :flag?

  end
end
