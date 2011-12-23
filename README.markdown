# Acclaim

Command-line option parsing and command interface.

## Introduction

Acclaim makes it easy to describe commands and options for a command-line
application in a structured manner. Commands are classes that inherit from
`Acclaim::Command`:

    require 'acclaim'

    module App
      class Command < Acclaim::Command
        option :verbose, '-v', '--verbose'

        when_called do |options, args|
          puts 'Hello World!'
          puts args.join ', ' if options.verbose? and args.any?
        end
      end
    end

    $ app --verbose a b c
    Hello World!
    a, b, c

Every command has a set of options and block that is executed when it is called.
The options are parsed into an object and passed to the command's block along
with the remaining command line arguments. The first argument of the `option`
method is the key used to store the value of the option, the other strings are
either switches or a description:

    option :verbose, '-v', '--verbose', '--run-verbosely', 'Run verbosely.'

Acclaim provides especial `help` and `version` commands that may be added to
your program. The help command will automatically generate and print a help page
for all commands and options. The version command will print your program's
version and exit. To use them:

    class App::Command
      help
      version '1.2.3'
    end

    $ app -h
    $ app --help
    $ app help

          -v, --verbose, --run-verbosely    Run verbosely.
          -h, --help    Show usage information and exit.
          -v, --version    Show version and exit.

    $ app -v
    $ app --version
    $ app version
    1.2.3

Both methods can take a hash as the last parameter, which accepts the same
configurations. If you don't want the options, or if you want to specify a
different set of switches or a different description, you can write something
like:

    help options: false
    version '1.2.3', switches: %w(--version),
                     description: "Shows this program's version."

### Subcommands

Essentially, a command given to another command. Subcommands benefit from all
the option processing done by its parents. To create one, you simply inherit
from an existing command:

    class App::Command::Do < App::Command

      # option is aliased as opt
      opt :what, '--what', 'What to do.', default: 'something', arity: [1, 0]

      # when_called is aliased as action
      action do |options, args|
        puts "Doing #{options.what} with #{args.join ', '}"
      end
    end

    $ app do x y, z
    Doing something with x y, z

    $ app do --what x y, z
    Doing x with y, z

Options may also take an Hash as the last parameter. Among the things that can
be configured is the default value for the option and its arity. The default
value is `nil` by default and is used if the option is not given. The arity of
the option represents the minimum number of arguments it __must__ take and the
number of optional arguments it __may__ take. It is specified as an array in the
form `[minimum, optional]`. Options that take zero arguments, which is the
default, are flags.

So, options can take from zero to an unlimited number of arguments, right?

    class App::Command::Do < App::Command

      # Negative number of optional arguments denote unlimited argument count
      opt :what, '--what', default: 'something', arity: [0, -1]

      action do |options, args|
        what = (options.what.join ', ' rescue options.what)
        subjects = args.join ', '
        puts "Doing #{what} with #{subjects}"
    end

    $ app do --what x y z
    Doing x, y, z with

Now, our option is eating up all the arguments in the command line! Hope is not
lost, however. Even though the list of arguments may be unlimited, parsing will
still stop if either another switch or an argument separator is encountered. An
argument separator is a group of two or more dashes:

    $ app do --what w x -- y z
    Doing w, x with y, z

An important thing to understand is that options are not parsed all at once;
first, the main command's options are parsed, then the remaining arguments are
searched for subcommands. If one is found, its options are parsed, the remaining
arguments are searched and so on. If a subcommand can't be found, the most
specific command found is executed.

Options are deleted from the command line as they are parsed, so the following
will not work:

    $ app do --what w x --verbose y z
    Doing w, x, y, z with

This happens because `--verbose` is an option of the main command. Since it will
be parsed and deleted from the argument array, when `do` gets its turn it will
be parsing the `%w(--what w x y z)` array.

### Option Type Handlers

Arguments given to options are by default strings. To make life easier, you may
specify the type of the arguments by passing a class among the arguments:

    class App::Command::Do
      opt :when, '--when', 'When to do it.', Date,
                 default: Date.today, arity: [1,0]

      action do |options, args|
        what = (options.what.join ', ' rescue options.what)
        subjects = args.join ', '
        date = options.when
        puts 'Merry Christmas!' if date.month == 12 and date.day == 25
        date = date.strftime '%m/%d/%Y'
        puts "Doing #{what} with #{subjects} on #{date}"
      end
    end

    $ app do --what w x --when 2011-12-25 y z
    Merry Christmas!
    Doing w, x with y, z on 12/25/2011

There are type handlers included for `Date`s, `Time`s, `DateTime`s, `URI`s and
`String`s, but if you need more you can always write your own:

    Acclaim::Option::Type.add_handler_for(Symbol) { |str| str.to_sym }

    class App::Command::Handle < App::Command
      opt :syms, '--symbol', '--symbols', Symbol, arity: [1,-1], required: true

      when_called do |options, args|
        options.syms.each { |sym| puts "#{sym.class} => #{sym.inspect}" }
      end
    end

    $ app handle --symbols a s d
    Symbol => :a
    Symbol => :s
    Symbol => :d

`add_handler_for` takes a class and a block, which will be called for every
argument of that class that must be parsed.

---

Originally extracted from [Safeguard](https://github.com/matheusmoreira/safeguard).
