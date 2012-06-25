# Command line option parsing and command interface for Ruby.
#
# @author Matheus Afonso Martins Moreira
# @since 0.0.1
module Acclaim
end

%w(

acclaim/ansi
acclaim/command
acclaim/gem
acclaim/option

).each { |file| require file }
