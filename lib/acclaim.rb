# Acclaim is a command line option parsing and command interface for Ruby.
module Acclaim
end

%w(command option version).each do |file|
  require file.prepend 'acclaim/'
end
