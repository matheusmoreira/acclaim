module Acclaim

  # Represents a command-line option.
  class Option

    attributes = %w(key names description arity default).map!(&:to_sym).freeze

    attr_accessor *attributes

    def initialize(args = {})
      args.each do |attribute, value|
        instance_variable_set :"@#{attribute}", value
      end
      yield self if block_given?
    end

    def =~(str)
      names.include? str.strip
    end

    def flag?
      not arity or arity.empty? or arity == [0, 0]
    end

    alias :bool?    :flag?
    alias :boolean? :flag?
    alias :switch?  :flag?

  end
end
