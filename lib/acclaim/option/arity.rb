module Acclaim
  class Option

    # Represents the the number of arguments an option can take, both mandatory
    # and optional.
    class Arity

      attr_accessor :minimum, :optional
      alias :required :minimum

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

      def to_a
        [ minimum, optional ]
      end

      alias :to_ary   :to_a
      alias :to_array :to_a

      def hash
        to_a.hash
      end

      def ==(arity)
        to_a == arity.to_a
      end

      alias :eql? :==
      alias :===  :==

      def to_s
        "Arity: #{minimum} +#{unlimited? ? 'infinite' : optional}"
      end

      alias :inspect :to_s

    end

  end
end
