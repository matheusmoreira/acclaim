%w(

acclaim/ansi
acclaim/io/terminal

).each { |file| require file }

Acclaim::ANSI.extend_string!

module Acclaim

  # High-level input/output.
  #
  # @author Matheus Afonso Martins Moreira
  # @since 0.6.0
  class IO
  end

end

class << Acclaim::IO

  # High-level input/output interface to the standard streams.
  #
  # @return [Acclaim::IO] high-level standard I/O interface
  def standard
    @standard ||= new
  end

  # Default formatting options for every context.
  #
  # @return [Ribbon] the output context associated with its default format
  def default_formats
    @default_formats ||= Ribbon.new
  end

end

class Acclaim::IO

  include Terminal

  default_formats.instance_eval do
    error :red
    warning :yellow
    information info :blue
    status :green, :bold
  end

  attr_accessor :input_stream, :output_stream, :error_stream

  # Encapsulates the specified input, output and error streams.
  #
  # @param [Hash, Ribbon, Ribbon::Raw] options method options
  # @option options [::IO, nil] :input (STDIN) the input stream
  # @option options [::IO, nil] :output (STDOUT) the output stream
  # @option options [::IO, nil] :error (STDERR) the error stream
  # @option options [true, false] :formatting (true) whether to enable text
  #   formatting
  def initialize(options = {})
    options = Ribbon.new options
    self.input_stream = options.input? STDIN
    self.output_stream = options.output? STDOUT
    self.error_stream = options.error? STDERR
    self.formatting = options.formatting? true
  end

  # Enables or disables formatted output support.
  #
  # @param [true, false] value whether formatted output is enabled
  def formatting=(value)
    @format = value
  end

  # Whether formatted output support is enabled.
  #
  # @return [true, false] whether output should be formatted
  def formatting?
    !!@format
  end

  # Enables formatted output support.
  def enable_formatting
    self.formatting = true
  end

  # Disables formatted output support.
  def disable_formatting
    self.formatting = false
  end

  # Enables or disables word wrapping.
  #
  # @param [true, false] value whether word wrapped output is enabled
  def word_wrapping=(value)
    @word_wrapping = value
  end

  # Whether word wrapping is enabled.
  #
  # @return [true, false] whether output should be word wrapped
  def word_wrapping?
    !!@word_wrapping
  end

  # Enables word wrapping.
  def enable_word_wrapping
    self.word_wrapping = true
  end

  # Disables word wrapping.
  def disable_word_wrapping
    self.word_wrapping = false
  end

  # Prints essential program output.
  #
  # @param [#to_s] message the output message
  # @param [Array<Symbol>] format the message's formatting options
  # @example
  #   io.output result
  def output(message, *format)
    write_to output_stream, message, format: format
  end

  # Prints a message to the user.
  #
  # @param [#to_s] message the message
  # @param [Array<Symbol>] format the message's formatting options
  # @example
  #   io.message 'Hello World!'
  def message(message, *format)
    write_to error_stream, message, format: format
  end

  # Prints error messages.
  #
  # @param [#to_s] string the error message
  # @param [Array<Symbol>] format the message's formatting options
  # @example
  #   begin
  #     some_operation
  #   rescue => error
  #     io.error error.message
  #   end
  def error(string, *format)
    format.push *self.class.default_formats.error if format.empty?
    message string, *format
  end

  # Prints warning messages.
  #
  # @param [#to_s] string the warning message
  # @param [Array<Symbol>] format the message's formatting options
  # @example
  #   io.warning 'WARNING: configuration file not found'
  def warning(string, *format)
    format.push *self.class.default_formats.warning if format.empty?
    message string, *format
  end

  # Prints information messages.
  #
  # @param [#to_s] string the information message
  # @param [Array<Symbol>] format the message's formatting options
  # @example
  #   io.info 'Entering directory...'
  #   # ...
  #   io.info 'Done.', :green
  def information(string, *format)
    format.push *self.class.default_formats.information if format.empty?
    message string, *format
  end

  alias info information

  # Prints the status followed by the details. The details will not be
  # formatted.
  #
  # @param [#to_s] symbol the symbolic status name
  # @param [#to_s] details the details
  # @param [Array<Symbol>] format the status name's formatting options
  # @example
  #   io.status :created, relative_path_to_file
  def status(symbol, details, *format)
    format.push *self.class.default_formats.status if format.empty?
    error_stream.tap do |stream|
      write_to stream, symbol.to_s.strip, format: format, method: :print
      write_to stream, ' ', method: :print, indent: false
      write_to stream, details, indent: false
    end
  end

  # The current identation level.
  #
  # @return [Integer] the number of spaces printed before text
  def indentation_level
    @indentation_level ||= 0
  end

  # Sets the indentation level.
  #
  # @param [Integer, #to_i] level the new identation level
  # @return [Integer] the new identation level
  def indentation_level=(level)
    @indentation_level = [0, level.to_i].max
  end

  # Executes the given block with the indentation level increased by the given
  # amount.
  #
  # @param [Integer] level the increase in identation
  # @return [Object] the return value of the block
  # @see #unindent
  def indent(level = 4)
    self.indentation_level += level
    yield
  ensure
    self.indentation_level -= level
  end

  # Executes the given block with the indentation level decreased by the given
  # amount.
  #
  # @param [Integer] level the decrease in identation
  # @return [Object] the return value of the block
  # @see #unindent
  def unindent(level = 4, &block)
    indent -level, &block
  end

  private

  # Generates a string with as many spaces as the current indentation level.
  #
  # @return [String] string used for indentation
  # @see #indentation_level
  def indentation
    ' ' * indentation_level
  end

  # Writes the message to the given stream with identation and formatting, if
  # appropriate.
  #
  # @param [::IO] stream the stream to write to
  # @param [#to_s] message the message to write
  # @param [Hash, Ribbon, Ribbon::Raw] options method options
  # @option options [Array<Symbol>] :format the formatting options to apply to
  #   the message
  # @option options [#to_sym] :method (:puts) the method to send to the stream
  # @option options [true, false] :indent (true) whether to indent the output
  # @see #identation_level
  # @see #supports_formatting?
  # @see #format
  def write_to(stream, message, options = {})
    return if stream.nil?

    options = Ribbon.new options
    message = message.to_s
    stream = stream.to_io
    method = options.method?(:puts).to_sym

    options.format! do |formatting_options|
      message = format message, *formatting_options if should_format_output_for? stream
    end

    message = indentation + message if should_indent = options.indent? true

    if options.word_wrap? { should_word_wrap_output_for? stream }
      width = if should_indent then line_width - indentation_level else line_width end
      message = word_wrap message, width
    end

    stream.send method, message unless message.empty?
  end

  # Whether formatting should be applied to output that will be written to the
  # given stream.
  #
  # @return [true, false] whether output to the given stream should be formatted
  def should_format_output_for?(stream)
    formatting? and stream.tty?
  end

  # Whether the output that will be written to the given stream should be word
  # wrapped.
  #
  # @return [true, false] whether output to the given stream should be word
  #   wrapped
  def should_word_wrap_output_for?(stream)
    word_wrapping? and stream.tty? and not line_width.nil?
  end

  # Applies the given formatting options to the message.
  #
  # @note The message must respond to all format symbols given.
  #
  # @param [#to_s] message the message to apply formatting to
  # @param [Array<Symbol>] format the list of formatting options to apply
  # @return [String] the message with the given formatting options applied
  # @see Acclaim::CoreExtensions::String::ANSI
  def format(message, *format)
    format.reduce message.to_s do |message, format|
      message.send format
    end
  end

end
