%w(

acclaim/option/arity
acclaim/option/parser/regexp
acclaim/option/type

ribbon
ribbon/core_extensions/array
ribbon/core_extensions/hash

).each { |file| require file }

module Acclaim

  # Command-line option.
  #
  # @author Matheus Afonso Martins Moreira
  # @since 0.0.1
  class Option

    # The key used to store the value of the option.
    attr_accessor :key

    # The strings that refer to this option in the command line.
    attr_accessor :names

    # The description of this option.
    attr_writer :description

    # The type the option's value will be converted to. See Option::Type.
    attr_accessor :type

    # The default value for the option. Default is +nil+.
    attr_accessor :default

    # This option's custom handler.
    attr_accessor :handler

    # How the parser should react when multiple instances of this option are
    # found in the command line. It will, by default, replace the old value with
    # the new one, but it can also collect all values or raise an error.
    attr_accessor :on_multiple

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
    # If no switches were specified, the +key+ will be used to derive one. See
    # Option::name_from for details.
    #
    # The last argument can be a hash of options, which may specify:
    #
    # [:arity]        The number of required and optional arguments. See Arity
    #                 for defails. Defaults to no arguments.
    # [:default]      The default value for this option. Defaults to +nil+.
    # [:description]  The description. Overrides the one given among the other
    #                 arguments.
    # [:required]     Whether or not the option must be present on the command
    #                 line. Default is +false+.
    # [:on_multiple]  What to do if the option is encountered multiple times.
    #                 Supported modes are <tt>:replace</tt>, <tt>:raise</tt> and
    #                 <tt>:append</tt> (or <tt>:collect</tt>). New values will
    #                 replace old ones by default.
    #
    # Additionally, if a block is given, it will be called when the option is
    # parsed with a ribbon instance and the parameters given to the option. The
    # parameters will already be converted to this option's specified type; if
    # this is not desirable consider not specifying a class to the option or
    # registering a custom type handler.
    def initialize(key, *args, &block)
      options = args.extract_ribbon!
      type = args.find { |arg| arg.is_a? Module }

      strings = args.flatten.select do |arg|
        arg.is_a? String
      end.group_by do |arg|
        arg =~ Parser::Regexp::SWITCH ? :switches : :description
      end.to_ribbon

      self.key = key
      self.names = strings.switches? { [ Option.name_from(key) ] }
      self.description = options.description? strings.description?([]).first
      self.on_multiple = options.on_multiple? :replace
      self.arity = options.arity?
      self.default = options.default?
      self.required = options.required?
      self.type = type || String
      self.handler = block
    end

    # Converts all given arguments using the type handler for this option's
    # type.
    def convert_parameters(*args)
      args.map { |arg| Type.handler_for(type).call arg }
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


    # Text that describes this option.
    #
    # @return [String] this option's description
    def description
      if @description.respond_to? :call then @description.call else @description end.to_s
    end

    # Whether or not this option is required on the command line.
    def required?
      @required
    end

    # Sets whether or not this option is required.
    def required=(value)
      @required = value ? true : false
    end

    # Require that this option be given on the command line.
    def require
      self.required = true
    end

    # Returns +true+ if this option takes no arguments.
    def flag?
      arity.none?
    end

    # Same as <tt>flag?</tt>
    alias bool? flag?

    # Same as <tt>flag?</tt>
    alias boolean? flag?

    # Same as <tt>flag?</tt>
    alias switch? flag?

    # Generate human-readable string containing this option's data.
    #
    # @return [String] human-readable representation of this option
    # @since 0.4.0
    def inspect
      '#<%s %s (%s) %s = %p (%s) (1+ => %s) %s>' % [
        self.class,
        key,
        names.join('|'),
        type,
        default,
        arity,
        on_multiple,
        if required? then :required else :optional end
      ]
    end

  end

  class << Option

    # Derives a name from the given key's string representation. All
    # underscores will be replaced with dashes.
    #
    # If the string is empty, an +ArgumentError+ will be raised. If the
    # resulting name is not a valid switch, a +NameError+ will be raised.
    def name_from(key)
      name = key.to_s
      raise ArgumentError, "Can't derive name from empty key." if name.empty?
      name = (name.length == 1 ? '-' : '--') + name
      name.gsub! '_', '-'
      raise NameError, "Derived name is invalid: #{name}" unless name =~ Option::Parser::Regexp::SWITCH
      name
    end

  end
end
