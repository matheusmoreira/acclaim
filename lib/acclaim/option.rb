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
    # @param [Array] arguments parameters specifying the description, switches
    #   and type
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
    def initialize(key, *arguments, &block)
      options = arguments.extract_ribbon!
      type = arguments.find { |arg| arg.is_a? Module }

      strings = arguments.flatten.select do |arg|
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
    def convert_parameters(*arguments)
      arguments.map { |argument| Type.handler_for(type).call argument }
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

    # Sets this option's description.
    #
    # If the given object responds to +call+, its return value will be used
    # {#description when the description is needed}.
    #
    # @param [String, #call] description text that describes this option
    # @example Internationalized description
    #   require 'acclaim'
    #
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
