#!/usr/bin/env gem build
# encoding: utf-8
$:.unshift File.expand_path('../lib', __FILE__)

require 'acclaim/version'

Gem::Specification.new('acclaim') do |gem|

  gem.version     = Acclaim::Version::STRING
  gem.summary     = 'Command-line option parser and command interface.'
  gem.description = gem.summary
  gem.homepage    = 'https://github.com/matheusmoreira/acclaim'

  gem.author = 'Matheus Afonso Martins Moreira'
  gem.email  = 'matheus.a.m.moreira@gmail.com'

  gem.files       = `git ls-files`.split "\n"

  gem.add_development_dependency 'rspec'

end
