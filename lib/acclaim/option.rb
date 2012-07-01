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

    # @!method initialize(key, *arguments, options = {}, &block)
    #
    # Initializes a new option.
    #
    # Command-line switches are specfied as strings or as an array of strings
    # that start with either <tt>'-'</tt> or <tt>'--'</tt>. The former specifies
    # a {Parser::Regexp::SHORT_SWITCH short switch} and the latter a
    # {Parser::Regexp::LONG_SWITCH long switch}.
    #
    # If no switches were specified, one will be {name_from derived} from the
    # key.
    #
    # Strings that don't follow the switch format are assumed to be
    # descriptions.
    #
    # The type is given as a module or class, and must be a registered {Type}.
    # Types are used in {#convert_parameters automatic parameter conversion}.
    # The default type is {Type::String String}.
    #
    # If given a block, it will be called when the option is found in the
    # command line. The block will receive a wrapped Ribbon as its first
    # argument. If the option takes parameters, they will be converted to the
    # option's type and passed as the second argument of the block.
    #
    # @param [Symbol] key the key used to associate this option with a value
    # @param [Array<String, Array<String>, Module, Class>] arguments parameters
    #   specifying the description, switches and type
    # @param [Hash, Ribbon, Ribbon::Wrapper] options method options
    # @param [Proc] block the custom option handler
    # @option options [Array, Arity] :arity ([0, 0]) the number of required and
    #   optional arguments
    # @option options [Object] :default (nil) the default value for this option
    # @option options [String, #call] :description the option's description
    # @option options [true, false] :required (false) whether the option must be
    #   present in the command line
    # @option options [:replace, :raise, :append, :collect] :on_multiple
    #   (:replace) what to do if multiple instances of the option are found in
    #   the command line
    # @example
    #   option = Acclaim::Option.new :directory, 'Directory to work in', Pathname, arity: [1, 0], default: Pathname.pwd
    def initialize(key, *arguments, &block)
      options = arguments.extract_ribbon!
      type = arguments.find { |argument| argument.is_a? Module }

      strings = arguments.flatten.select do |argument|
        argument.is_a? String
      end.group_by do |argument|
        if argument =~ Parser::Regexp::SWITCH then :switches else :description end
      end.to_ribbon

      self.key = key
      self.names = strings.switches? { [ Option.name_from(key) ] }
      self.description = options.description? { strings.description?([]).first }
      self.on_multiple = options.on_multiple? :replace
      self.arity = options.arity?
      self.default = options.default?
      self.required = options.required?
      self.type = type || String
      self.handler = block
    end

    # Converts all given arguments using the type handler for this option's
    # type.
    #
    # @param [Array<String>] arguments the arguments to convert
    # @return [Array] the arguments converted to this option's type
    def convert_parameters(*arguments)
      arguments.map { |argument| Type.handler_for(type).call argument }
    end

    # Whether the given string matches any of {#names this option's names}.
    #
    # @param [String, #to_s] string the string to be matched
    # @return [true, false] whether the string refers to this option
    def =~(string)
      names.include? string.to_s.strip
    end

    # This option's {Arity arity}.
    #
    # @return [Arity] this option's arity
    def arity
      @arity ||= Arity.new
    end

    # Sets this option's {Arity arity}.
    #
    # @param [Arity, Array] arity the arity or the arguments to create a new one
    # @example Setting the arity to an {Arity} instance
    #   option.arity = Acclaim::Option::Arity.new 1, 0
    # @example Setting the arity to an array
    #   option.arity = [1, 0]
    def arity=(arity)
      @arity = if arity.is_a? Arity then arity else Arity.new *arity end
    end

    # Sets this option's description.
    #
    # If the given object responds to +call+, its return value will be used
    # {#description when the description is needed}.
    #
    # @param [String, #call] description text that describes this option
    # @example Internationalized description
    #   option = Acclaim::Option.new :verbose
    #
    #   option.description = lambda do
    #     I18n.translate 'application.options.verbose.description'
    #   end
    def description=(description)
      @description = description
    end

    # Text that describes this option.
    #
    # @return [String] this option's description
    def description
      if @description.respond_to? :call then @description.call else @description end.to_s
    end

    # Whether or not this option must be present in the command line.
    #
    # @return [true, false] whether this option must be specified
    def required?
      @required
    end

    # Sets whether or not this option is required.
    #
    # @param [true, false] required whether this option must be specified
    def required=(required)
      @required = !!required
    end

    # Require that this option be given on the command line.
    def require
      @required = true
    end

    # Whether this option takes no arguments.
    #
    # @return [true, false] whether this option takes zero arguments
    def flag?
      arity.none?
    end

    alias bool? flag?
    alias boolean? flag?
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
    def derive_switch_from(key)
      key = key.to_s
      raise ArgumentError, "Can't derive switch from empty string." if key.empty?
      switch = (key.length == 1 ? '-' : '--') + key
      switch.gsub! '_', '-'
      raise NameError, "Derived switch is invalid: #{switch}" unless switch =~ Option::Parser::Regexp::SWITCH
      switch
    end

    alias name_from derive_switch_from

  end
end
