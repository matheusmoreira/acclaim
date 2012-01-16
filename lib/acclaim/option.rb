require 'acclaim/option/arity'
require 'acclaim/option/parser/regexp'
require 'acclaim/option/type'
require 'ribbon'
require 'ribbon/core_ext/array'

module Acclaim

  # Represents a command-line option.
  class Option

    attr_accessor :key, :names, :description, :type, :default, :handler, :on_multiple

    # Initializes a command line option. The +key+ is the object used to
    # associate this option with a value. The other arguments may be:
    #
    # [short switches]  Strings starting with <tt>'-'</tt>, like:
    #                   <tt>'-h'</tt>; <tt>'-v'</tt>
    # [long switches]   Strings starting with <tt>'--'</tt>, like:
    #                   <tt>'--help'</tt>; <tt>'--version'</tt>
    # [description]     Strings that don't start with either <tt>'-'</tt>
    #                   nor <tt>'--'</tt>, like:
    #                   <tt>'Display this help text and exit.'</tt>;
    #                   <tt>'Display version and exit.'</tt>
    # [class]           The <tt>Class</tt> which will be used in parameter
    #                   conversion. The default is <tt>String</tt>.
    #
    # The last argument can be a hash of options, which may specify:
    #
    # [:arity]     The number of required and optional arguments. See Arity for
    #              defails.
    # [:default]   The default value for this option.
    # [:required]  Whether or not the option must be present on the command
    #              line.
    #
    # Additionally, if a block is given, it will be called when the option is
    # parsed with a ribbon instance and the parameters given to the option. The
    # parameters will already be converted to this option's specified type; if
    # this is not desirable consider not specifying a class to the option or
    # registering a custom type handler.
    def initialize(key, *args, &block)
      options = args.extract_ribbon!
      matches = args.select do |arg|
        arg.is_a? String
      end.group_by do |arg|
        arg =~ Parser::Regexp::SWITCH ? true : false
      end
      klass = args.find { |arg| arg.is_a? Module }
      self.key         = key
      self.names       = matches.fetch true, []
      self.description = matches.fetch(false, []).first
      self.on_multiple = options.on_multiple? :replace
      self.arity       = options.arity?
      self.default     = options.default?
      self.required    = options.required?
      self.type        = klass || String
      self.handler     = block
    end

    # Converts all given arguments using the type handler for this option's
    # type.
    def convert_parameters(*args)
      args.map { |arg| Type[type].call arg }
    end

    # Returns true if the given string is equal to any of this option's names.
    def =~(str)
      names.include? str.strip
    end

    # Returns this option's arity. See Arity for details.
    def arity
      @arity ||= Arity.new
    end

    # Sets this option's arity. The value given may be an Arity, or an array in
    # the form of <tt>[ required_parameters, optional_parameters ]</tt>.
    def arity=(arity_or_array)
      @arity = if arity.nil? or arity_or_array.is_a? Arity
        arity_or_array
      else
        Arity.new *arity_or_array
      end
    end

    # Whether or not this option is required on the command line.
    def required?
      @required
    end

    # Sets whether or not this option is required.
    def required=(value)
      @required = (value ? true : false)
    end

    # Require that this option be given on the command line.
    def require
      self.required = true
    end

    # Returns true if this option takes no arguments.
    def flag?
      not arity or arity == [0, 0]
    end

    alias :bool?    :flag?
    alias :boolean? :flag?
    alias :switch?  :flag?

  end
end
