%w(

acclaim/io/terminal/error

ribbon

).each { |file| require file }

module Acclaim
  class IO

    # Terminal-specific functionality.
    #
    # @author Matheus Afonso Martins Moreira
    # @since 0.6.0
    module Terminal
    end

    class << Terminal

      # Terminal measurement algorithms stored in execution order.
      #
      # @return [Ribbon<Symbol, Proc>] algorithms identified by symbols
      def measurement_algorithms
        @measurement_algorithms ||= Ribbon.new
      end

    end

    module Terminal

      extend self

      # Uses various methods to find out the dimensions of the terminal.
      #
      # @return [Array<Integer>, nil] the number of lines and columns of the
      #   terminal, or +nil+ if it couldn't be determined
      def measurements
        measurement_algorithms.each do |key, algorithm|
          begin
            @terminal_measurements = algorithm.call.to_a.map &:to_i
            break
          rescue Terminal::Error
            next
          end
        end if @terminal_measurements.nil?

        @terminal_measurements
      end

      alias dimensions measurements
      alias size measurements

      # The number of lines of the terminal
      #
      # @return [Integer] the number of lines of the terminal
      def lines
        measurements and measurements.first
      end

      # The number of columns of the terminal
      #
      # @return [Integer] the number of columns of the terminal
      def columns
        measurements and measurements.last
      end

      alias line_width columns

      private

      # Stores the given block as a measurement algorithm.
      #
      # @param [#to_sym] key the key that identifies the algorithm
      # @param [#call] block the block to be stored
      # @yieldreturn [Array<Integer>] an array containg the number of lines and
      #   columns of the terminal as its first and last element, respectively
      def measurement_algorithm(key, &block)
        Terminal.measurement_algorithms[key.to_sym] = block if block.respond_to? :call
      end

      alias compute_terminal_dimensions_using measurement_algorithm

      # Uses the values of the +LINES+ and +COLUMNS+ environment variables as
      # terminal dimensions.
      #
      # @return [Array<Integer>] the number of lines and columns of the terminal
      compute_terminal_dimensions_using :environment_variables do
        lines, columns, regexp = ENV['LINES'], ENV['COLUMNS'], /\A\d+\Z/ix
        if lines =~ regexp and columns =~ regexp then [lines, columns]
        else raise Terminal::Error end
      end

      # Uses Ruby's Curses library to obtain terminal dimensions.
      #
      # @return [Array<Integer>] the number of lines and columns of the terminal
      compute_terminal_dimensions_using :curses do
        begin
          require 'curses'
          begin
            Curses.init_screen
            [ Curses.lines, Curses.cols ]
          ensure
            Curses.close_screen
          end
        rescue LoadError
          raise Terminal::Error
        end
      end

    end

  end
end
