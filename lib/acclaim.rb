# Acclaim is a command line option parsing and command interface for Ruby.
module Acclaim
end

%w(command gem option).each do |file|
  require file.prepend 'acclaim/'
end
