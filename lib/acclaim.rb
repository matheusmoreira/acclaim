# Command line option parsing and command interface for Ruby.
#
# @author Matheus Afonso Martins Moreira
# @since 0.0.1
module Acclaim
end

%w(command gem option).each do |file|
  require file.prepend 'acclaim/'
end
