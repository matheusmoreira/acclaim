%w(

command
option
option/arity
option/parser
option/parser/regexp
option/values
version

).each { |file| require file.prepend 'acclaim/' }
