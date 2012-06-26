# encoding: utf-8

module Acclaim
  class Option

    # Represents the the number of arguments an option can take, both mandatory
    # and optional.
    #
    # @author Matheus Afonso Martins Moreira
    class Arity

      # The minimum number of arguments.
      attr_accessor :minimum

      # The number of optional arguments.
      attr_accessor :optional

      alias required minimum

      # Initializes an arity with the given number of required and optional
      # parameters. If the latter is less than zero, then it means the option
      # may take infinite parameters, as long as it takes the minimum number of
      # parameters.
      #
      # @param [Integer] minimum the number of mandatory parameters
      # @param [Integer] optional the number of optional parameters
      def initialize(minimum = 0, optional = 0)
        @minimum, @optional = minimum, optional
      end

      # Whether the option takes +n+ and only +n+ parameters.
      #
      # @param [Integer] n the number of parameters
      # @return [true, false] whether the option takes only +n+ parameters
      def only?(n)
        optional.zero? and minimum == n
      end

      # Whether the option takes no parameters.
      #
      # @return [true, false] whether the option takes zero parameters
      def zero?
        only? 0
      end

      alias none? zero?

      # Whether the option can take an unlimited number of arguments.
      #
      # @return [true, false] whether the option can take infinite parameters
      def unlimited?
        optional < 0
      end

      # Whether the option must take a finite number of arguments.
      #
      # @return [true, false] whether the maximum number of arguments is limited
      # @see #total
      def bound?
        not unlimited?
      end

      # The total number of parameters that the option may take, or +nil+ if the
      # option can take an infinite number of arguments.
      #
      # @return [Integer, nil] the total number of parameters or nil if infinite
      def total
        if bound? then minimum + optional else nil end
      end

      # Converts this arity to an array in the form of
      # <tt>[ required, optional ]</tt>.
      def to_a
        [ minimum, optional ]
      end

      # Same as +to_a+.
      alias to_ary   to_a

      # Same as +to_a+.
      alias to_array to_a

      # Equivalent to <tt>to_a.hash</tt>.
      def hash
        to_a.hash
      end

      # Converts both +self+ and +arity+ to an array and compares them. This is
      # so that comparing directly with an array is possible:
      #
      #   Arity.new(1, 3) == [1, 3]
      #   => true
      def ==(arity)
        to_a == arity.to_a
      end

      # Same as <tt>==</tt>
      alias eql? ==

      # Same as <tt>==</tt>
      alias ===  ==

      # Returns a string in the following format:
      #
      #   minimum +optional
      #
      # The value of optional will be ∞ if this arity is not {#bound? bound}.
      #
      # @return [String] string representation of this arity
      # @see #inspect
      def to_s
        "#{minimum} +#{unlimited? ? '∞' : optional}"
      end

      # Returns a string in the following format:
      #
      #   #<Acclaim::Option::Arity minimum +optional>
      #
      # @return [String] human-readable representation of this arity object
      # @see #to_s
      def inspect
        "#<#{self.class} #{to_s}>"
      end

    end

  end
end
