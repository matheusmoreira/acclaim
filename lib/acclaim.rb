%w(

command
option
version

).each { |file| require file.prepend 'acclaim/' }
