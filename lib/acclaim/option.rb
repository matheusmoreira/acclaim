require 'acclaim/option/arity'
require 'acclaim/option/parser/regexp'
require 'acclaim/option/type'

module Acclaim

  # Represents a command-line option.
  class Option

    attr_accessor :key, :names, :description, :type, :default, :handler

    def initialize(key, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      matches = args.select { |arg| arg.is_a? String }.group_by do |arg|
        arg =~ Parser::Regexp::SWITCH ? true : false
      end
      klass = args.find { |arg| arg.is_a? Class }
      self.key         = key
      self.names       = matches.fetch true, []
      self.description = matches.fetch(false, []).first
      self.arity       = options[:arity]
      self.default     = options[:default]
      self.required    = options[:required]
      self.type        = klass
      self.handler     = block
    end

    def convert_parameters(*args)
      args.map { |arg| Type[type].call arg }
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
