module Acclaim
  class Option

    # Represents the the number of arguments an option can take, both mandatory
    # and optional.
    class Arity

      # The minimum number of arguments.
      attr_accessor :minimum

      # The number of optional arguments.
      attr_accessor :optional

      # Same as +minimum+.
      alias required minimum

      # Initializes this arity with a number of required parameters and a number
      # of optional parameters. If the latter is less than zero, then it means
      # the option may take infinite parameters, as long as it takes at least
      # +minimum+ parameters.
      def initialize(minimum = 0, optional = 0)
        @minimum, @optional = minimum, optional
      end

      # Returns +true+ if the option takes +n+ and only +n+ parameters.
      def only?(n)
        optional.zero? and minimum == n
      end

      # Returns +true+ if the option takes no parameters.
      def none?
        only? 0
      end

      # Returns +true+ if the option can take an infinite number of arguments.
      def unlimited?
        optional < 0
      end

      # Returns +true+ if the option must take a finite number of arguments.
      def bound?
        not unlimited?
      end

      # Returns the total number of parameters that the option may take, which
      # is the number of mandatory parameters plus the number of optional
      # parameters. Returns +nil+ if the option may take an infinite number of
      # parameters.
      def total
        bound? ? minimum + optional : nil
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
      #   Arity: minimum +optional
      #
      # The value of +optional+ will be <tt>'infinite'</tt> if #unlimited? is
      # +true+.
      def to_s
        "Arity: #{minimum} +#{unlimited? ? 'infinite' : optional}"
      end

      # Returns the output of #to_s, enclosed in angle brackets (<tt>'<'</tt>
      # and <tt>'>'</tt>).
      def inspect
        "<#{to_s}>"
      end

    end

  end
end
